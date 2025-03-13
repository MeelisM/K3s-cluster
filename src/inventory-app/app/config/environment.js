import dotenv from "dotenv";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: join(__dirname, "/../../.env") });

const config = {
  server: {
    port: process.env.INVENTORY_PORT,
    host: process.env.INVENTORY_HOST,
  },
  database: {
    username: process.env.INVENTORY_DB_USER,
    password: process.env.INVENTORY_DB_PASSWORD,
    database: process.env.INVENTORY_DB_NAME,
    host: process.env.INVENTORY_DB_HOST,
    port: process.env.INVENTORY_DB_PORT,
    dialect: "postgres",
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  },
};

export default config;
