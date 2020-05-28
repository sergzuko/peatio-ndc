# frozen_string_literal: true

RSpec.describe Peatio::Ndc::Blockchain do
  context :features do
    it "defaults" do
      blockchain1 = Peatio::Ndc::Blockchain.new
      expect(blockchain1.features).to eq Peatio::Ndc::Blockchain::DEFAULT_FEATURES
    end

    it "override defaults" do
      blockchain2 = Peatio::Ndc::Blockchain.new(cash_addr_format: true)
      expect(blockchain2.features[:cash_addr_format]).to be_truthy
    end

    it "custom feautures" do
      blockchain3 = Peatio::Ndc::Blockchain.new(custom_feature: :custom)
      expect(blockchain3.features.keys).to contain_exactly(*Peatio::Ndc::Blockchain::SUPPORTED_FEATURES)
    end
  end

  context :configure do
    let(:blockchain) { Peatio::Ndc::Blockchain.new }
    it "default settings" do
      expect(blockchain.settings).to eq({})
    end

    it "currencies and server configuration" do
      currencies = [{id: :ndc,
                      base_factor: 100_000_000,
                      options: {}}]
      settings = {server: "http://admin:adminpass@127.0.0.1:27798",
                   currencies: currencies,
                   something: :custom}
      blockchain.configure(settings)
      expect(blockchain.settings).to eq(settings.slice(*Peatio::Blockchain::Abstract::SUPPORTED_SETTINGS))
    end
  end

  context :latest_block_number do
    before(:all) { WebMock.disable_net_connect! }
    after(:all)  { WebMock.allow_net_connect! }

    let(:server) { "http://admin:adminpass@127.0.0.1:27798" }
    let(:server_without_authority) { "http://127.0.0.1:27798" }

    let(:response) do
      JSON.parse(File.read(response_file))
    end

    let(:response_file) do
      File.join("spec", "resources", "getblockcount", "response.json")
    end

    let(:blockchain) do
      Peatio::Ndc::Blockchain.new.tap {|b| b.configure(server: server) }
    end

    before do
      stub_request(:post, server_without_authority)
        .with(body: {jsonrpc: "1.0",
                      method: :getblockcount,
                      params:  []}.to_json)
        .to_return(body: response.to_json)
    end

    it "returns latest block number" do
      expect(blockchain.latest_block_number).to eq(425)
    end

    it "raises error if there is error in response body" do
      stub_request(:post, "http://127.0.0.1:27798")
        .with(body: {jsonrpc: "1.0",
                      method: :getblockcount,
                      params:  []}.to_json)
        .to_return(body: {result: nil,
                           error:  {code: -32_601, message: "Method not found"},
                           id:     nil}.to_json)

      expect { blockchain.latest_block_number }.to raise_error(Peatio::Blockchain::ClientError)
    end
  end

   context :fetch_block! do
    before(:all) { WebMock.disable_net_connect! }
    after(:all)  { WebMock.allow_net_connect! }

    let(:server) { "http://admin:adminpass@127.0.0.1:27798" }
    let(:server_without_authority) { "http://127.0.0.1:27798" }

    let(:getblockhash_response_file) do
      File.join("spec", "resources", "getblockhash", "421.json")
    end

    let(:getblockhash_response) do
      JSON.parse(File.read(getblockhash_response_file))
    end

    let(:getblock_response_file) do
      File.join("spec", "resources", "getblock", "421.json")
    end

    let(:getblock_response) do
      JSON.parse(File.read(getblock_response_file))
    end

    let(:blockchain) do
      Peatio::Ndc::Blockchain.new.tap {|b| b.configure(server: server) }
    end

    before do
      stub_request(:post, server_without_authority)
        .with(body: {jsonrpc: "1.0",
                      method: :getblockhash,
                      params:  [421]}.to_json)
        .to_return(body: getblockhash_response.to_json)

      stub_request(:post, server_without_authority)
        .with(body: {jsonrpc: "1.0",
                      method: :getblock,
                      params:  ["b8e04d045d17233af93631459f0a5f9b85022cb15261ce9dfbb31675829efda6", 2]}.to_json)
        .to_return(body: getblock_response.to_json)
    end

    let(:currency) do
      {id: :ndc,
        base_factor: 100_000_000,
        options: {}}
    end

    context :load_balance_of_address! do
    before(:all) { WebMock.disable_net_connect! }
    after(:all)  { WebMock.allow_net_connect! }

    let(:server) { "http://admin:adminpass@127.0.0.1:27798" }
    let(:server_without_authority) { "http://127.0.0.1:27798" }

    let(:response) do
      JSON.parse(File.read(response_file))
    end

    let(:response_file) do
      File.join("spec", "resources", "listaddressgroupings", "response.json")
    end

    let(:blockchain) do
      Peatio::Ndc::Blockchain.new.tap {|b| b.configure(server: server) }
    end

    before do
      stub_request(:post, server_without_authority)
        .with(body: {jsonrpc: "1.0",
                      method: :listaddressgroupings,
                      params:  []}.to_json)
        .to_return(body: response.to_json)
    end

    context "address with balance is defined" do
      it "requests rpc listaddressgroupings and finds address balance" do
        address = "mi1mQjHnuitrHuyxY8SSadApAAB7E6yktx"
        result = blockchain.load_balance_of_address!(address, :ndc)
        expect(result).to be_a(BigDecimal)
        expect(result).to eq("0.1e2".to_d)
      end

      it "requests rpc listaddressgroupings and finds address with zero balance" do
        address = "mifMu94mMhrtaneCtsh1LCN9o5Pv97DrHN"
        result = blockchain.load_balance_of_address!(address, :ndc)
        expect(result).to be_a(BigDecimal)
        expect(result).to eq("0.00".to_d)
      end
    end

    context "address is not defined" do
      it "requests rpc listaddressgroupings and do not find address" do
        address = "mY75oNb6FVY5qWx7nrfARNVwRyHwLoXcQu"
        expect { blockchain.load_balance_of_address!(address, :ndc) }
          .to raise_error(Peatio::Blockchain::UnavailableAddressBalanceError)
      end
    end

    context "client error is raised" do
      before do
        stub_request(:post, "http://127.0.0.1:27798")
          .with(body: {jsonrpc: "1.0",
                        method: :listaddressgroupings,
                        params: []}.to_json)
          .to_return(body: {result: nil,
                             error:  {code: -32_601, message: "Method not found"},
                             id:     nil}.to_json)
      end

      it "raise wrapped client error" do
        expect { blockchain.load_balance_of_address!("anything", :ndc) }
          .to raise_error(Peatio::Blockchain::ClientError)
      end
    end
  end
end
end
