type CardProps = {
    name: string;
    title: string;
    rate: string;
    description?: string;
    slots: string[];
    imageUrl: string;
}


export function Card({name, title, imageUrl, slots, rate}: CardProps) {

  return (
    <div className="w-full max-w-sm bg-white border  border-gray-200 p-5 rounded-lg shadow-sm dark:bg-gray-800 dark:border-gray-700">
      <div className="flex flex-col p-10 items-center space-y-4">
        <img
          className="w-24 h-24 mb-3 rounded-full shadow-lg"
          src={imageUrl}
          alt="Bonnie image"
        />
        <h5 className="mb-1 text-xl font-medium text-gray-900 dark:text-white">
          {name}
        </h5>
        <span className="flex space-x-3 text-sm text-gray-500 dark:text-gray-400">
          {title}
        </span>
        <span className="flex space-x-3 text-sm text-gray-500 dark:text-gray-400">
          {rate}
        </span>
        <div className="flex mt-4 space-x-4 lg:mt-6">
        {
            slots.map((slot, i) => ( 
                <button type="button" key={i} className="text-gray-900 bg-white border border-gray-300 focus:outline-none hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700">{slot}</button>
            ))
        }
        </div>
        <div className="flex mt-4 md:mt-6">
          <a
            href="#"
            className="inline-flex items-center px-4 py-2 text-sm font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:outline-none focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
          >
            Add friend
          </a>
        </div>
      </div>
    </div>
  );
}
