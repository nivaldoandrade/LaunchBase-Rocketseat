CREATE DATABASE launchstoredb;

CREATE TABLE "products" (
  "id" SERIAL PRIMARY KEY,
  "category_id" int,
  "user_id" int,
  "name" text NOT NULL,
  "description" text NOT NULL,
  "old_price" int,
  "price" int NOT NULL,
  "quantity" int DEFAULT 0,
  "status" int DEFAULT 1,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "categories" (
  "id" SERIAL PRIMARY KEY,
  "name" text NOT NULL
);

CREATE TABLE "files" (
  "id" SERIAL PRIMARY KEY,
  "product_id" int,
  "name" text NOT NULL,
  "path" text NOT NULL
);

ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("id");

ALTER TABLE "files" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("id");

CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "name" text NOT NULL,
  "email" text UNIQUE NOT NULL,
  "password" text NOT NULL,
  "cpf_cnpj" text NOT NULL,
  "cep" text,
  "address" text,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

ALTER TABLE users ADD COLUMN reset_token text;
ALTER TABLE users ADD COLUMN reset_token_expires text;

ALTER TABLE "products" ADD FOREIGN KEY ("user_id") REFERENCES "users"("id");


CREATE FUNCTION trigger_set_timestamp() 
RETURNS TRIGGER AS $$
BEGIN
  NEW.uptaded_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

  
CREATE TABLE "session" (
  "sid" varchar NOT NULL COLLATE "default",
	"sess" json NOT NULL,
	"expire" timestamp(6) NOT NULL
)
WITH (OIDS=FALSE);

ALTER TABLE "session" ADD CONSTRAINT "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX "IDX_session_expire" ON "session" ("expire");

ALTER TABLE products
ADD CONSTRAINT products_user_id_fkey
FOREIGN KEY ("user_id")
REFERENCES users ("id")
ON DELETE CASCADE;

ALTER TABLE files
DROP CONSTRAINT files_product_id_fkey,
ADD CONSTRAINT files_product_id_fkey
FOREIGN KEY ("product_id")
REFERENCES products("id")
ON DELETE CASCADE;