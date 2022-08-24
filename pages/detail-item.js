/* eslint-disable react-hooks/exhaustive-deps */
import { ethers } from "ethers";
import { useEffect, useState } from "react";
import axios from "axios";
import Web3Modal from "web3modal";
import { useRouter } from "next/router";

import { marketplaceAddress } from "../config";

import NFTMarketplace from "../artifacts/contracts/NFTMarketplace.sol/NFTMarketplace.json";
import Image from "next/image";

export default function CreatorDashboard() {
  const router = useRouter();
  const { id } = router.query;
  const [nft, setNft] = useState();
  useEffect(() => {
    loadNFT();
    console.log(nft);
  }, []);

  async function loadNFT() {
    const web3Modal = new Web3Modal({
      network: "mainnet",
      cacheProvider: true,
    });
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();

    const contract = new ethers.Contract(marketplaceAddress, NFTMarketplace.abi, signer);
    const data = await contract.fetchMarketItem(id);

    const tokenUri = await contract.tokenURI(data.tokenId);
    const meta = await axios.get(tokenUri);
    let price = ethers.utils.formatUnits(data.price.toString(), "ether");
    let item = {
      price,
      tokenid: data.tokenId.toNumber(),
      seller: data.seller,
      owner: data.owner,
      image: meta.data.image,
      name: meta.data.name,
      description: meta.data.description,
    };
    console.log(item);
    setNft(item);
  }
  async function buyNft(nft) {
    const web3Modal = new Web3Modal();
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(marketplaceAddress, NFTMarketplace.abi, signer);
    const price = ethers.utils.parseUnits(nft.price.toString(), "ether");
    const transaction = await contract.createMarketSale(nft.tokenId, { value: price });
    await transaction.wait();
    loadNFT();
  }
  if (!nft) {
    return <h1>Loding</h1>;
  }
  return (
    <div className="flex justify-center">
      <div className="grid h-screen pt-20">
        <div className="grid grid-cols-2 gap-4 place-items-stretch h-56">
          <div>
            <img className="shadow-2xl rounded-lg" src={nft.image} />
          </div>
          <div>
            <div className="grid grid-cols-1 gap-4 place-items-stretch h-56">
              <div className="text-lg text-center">{nft.name}</div>
              <hr />
              <div className="p-2">Owner : {nft.owner}</div>
              <div className="p-2">Seller : {nft.seller}</div>
              <hr />
              <div className="p-2 text-lg">Description : </div>
              <div className="pl-5">{nft.description}</div>
              <div className="p-4 mt-10 bg-black rounded-lg">
                <p className="text-2xl font-bold text-white">{nft.price} ETH</p>
                <button className="mt-4 w-full bg-amber-500 text-white font-bold py-2 px-12 rounded" onClick={() => buyNft(nft)}>
                  Buy
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
