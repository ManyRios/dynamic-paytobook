import { useState, useEffect } from "react";
import {
  useDynamicContext,
  useIsLoggedIn,
  useUserWallets,
} from "@dynamic-labs/sdk-react-core";
import { isEthereumWallet } from "@dynamic-labs/ethereum";
import { Card } from "./Cards";
import { experts } from "../utils/config";
import "./Methods.css";

export default function DynamicMethods({
  isDarkMode,
}: {
  isDarkMode: boolean;
}) {
  const isLoggedIn = useIsLoggedIn();
  const { sdkHasLoaded, primaryWallet, user } = useDynamicContext();
  /* const userWallets = useUserWallets();
  const [selectedExpert, setSelectedExpert] = useState(null);
  const [selectedSlot, setSelectedSlot] = useState(null);
  const [bookingConfirmed, setBookingConfirmed] = useState(false); */
  const [isLoading, setIsLoading] = useState(true);
  /* const [result, setResult] = useState<undefined | string>(undefined);
  const [error, setError] = useState<string | null>(null); */

  const safeStringify = (obj: unknown): string => {
    const seen = new WeakSet();
    return JSON.stringify(
      obj,
      (key, value) => {
        if (typeof value === "object" && value !== null) {
          if (seen.has(value)) {
            return "[Circular]";
          }
          seen.add(value);
        }
        return value;
      },
      2
    );
  };

  useEffect(() => {
    if (sdkHasLoaded && isLoggedIn && primaryWallet) {
      setIsLoading(false);
    } else {
      setIsLoading(true);
    }
  }, [sdkHasLoaded, isLoggedIn, primaryWallet]);


  
  return (
    <>
      {!isLoggedIn && <h1 className="title">Log in to use the app</h1>}
      {!isLoading && (
        <div
          className="flex flex-wrap w-full h-full items-center flex-row justify-center gap-4 p-4"
          data-theme={isDarkMode ? "dark" : "light"}
        >
          {
            experts.map((expert) => (
              <Card
                key={expert.id}
                name={expert.name}
                title={expert.title}
                imageUrl={expert.image}
                rate={expert.rate}
                slots={expert.slots}
              />
            ))
          }
        
        </div>
      )}
    </>
  );
}
