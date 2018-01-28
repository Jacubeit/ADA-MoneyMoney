-- Inofficial ADA (Cardano) for MoneyMoney
-- Fetches ADA quantity for address via cardanoexplorer API
-- Fetches Ether price in EUR via coinmarketcap API
-- Returns cryptoassets as securities
--
-- Username: ADA Adresses comma seperated
-- Password: whatever

-- MIT License

-- Copyright (c) 2018 Jacubeit

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 0.1,
  description = "Include your ADA coins as cryptoportfolio in MoneyMoney by providing an ADA address (usernme, comma seperated) and a random Password",
  services= { "ADA" }
}

local adaAddress
local connection = Connection()
local currency = "EUR" -- fixme: make dynamik if MM enables input field

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "ADA"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  adaAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "ADA",
    accountNumber = "Crypto Asset ADA",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestADAPrice()

  for address in string.gmatch(adaAddress, '([^,]+)') do
    adaQuantity = requestAdaQuantityForAdaAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "coinmarketcap",
      quantity = adaQuantity:dictionary()["Right"]["caBalance"]["getCoin"],
      price = prices["price_eur"],
    }

  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestADAPrice()
  content = connection:request("GET", coinmarketCapRequestUrl(), {})
  json = JSON(content)

  return json:dictionary()[1]
end


function requestAdaQuantityForAdaAddress(adaAddress)
  content = connection:request("GET", adaRequestUrl(adaAddress), {})
  json = JSON(content)
  
  return json
end


-- Helper Functions
function coinmarketCapRequestUrl()
  return "https://api.coinmarketcap.com/v1/ticker/cardano/?convert=EUR"
end 

function adaRequestUrl(adaAddress)
  adaChain = "http://cardanoexplorer.com/api/addresses/summary/"
  return adaChain .. adaAddress
end

