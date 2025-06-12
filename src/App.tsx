import { DynamicWidget } from "@dynamic-labs/sdk-react-core";
import { useDarkMode } from "./lib/useDarkMode";
import DynamicMethods from "./components/Methods";

function App() {
  const { isDarkMode } = useDarkMode();

  return (
    <div className={`
      min-h-screen flex flex-col items-center p-4 justify-start text-[#333] relative w-full overflow-hidden
      bg-gray-900`}
        style={{ transition: "background-color 0.3s ease" }}
      >
      <div className="header">
        <img
          className="logo"
          src={isDarkMode ? "/logo-light.png" : "/logo-dark.png"}
          alt="dynamic"
        />
      </div>

      <div className="modal">
        <DynamicWidget />
      </div>
      <div className="content">
        <DynamicMethods isDarkMode={isDarkMode} />
      </div>

      <div className="footer">
        <div className="footer-text">Made with Manuel Rios with Dynamic</div>
        <img
          className="footer-image"
          src={isDarkMode ? "/image-dark.png" : "/image-light.png"}
          alt="dynamic"
        />
      </div>
    </div>
  );
}

export default App;
