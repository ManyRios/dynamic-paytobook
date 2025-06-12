import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { EthereumWalletConnectors } from "@dynamic-labs/ethereum";
import { SolanaWalletConnectors } from "@dynamic-labs/solana";
import { DynamicContextProvider } from "@dynamic-labs/sdk-react-core";

import App from "./App";
import "./index.css";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <DynamicContextProvider
      theme="auto"
      settings={{
        environmentId: import.meta.env.VITE_DYNAMIC_ENVIRONMENT_ID,
        appName: "Dynamic Pay-Book",
        walletConnectors: [EthereumWalletConnectors, SolanaWalletConnectors],
      }}
    >
      <App />
    </DynamicContextProvider>
  </StrictMode>
);