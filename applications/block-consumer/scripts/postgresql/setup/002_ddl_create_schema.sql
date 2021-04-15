--------------------------------------------------------
-- create schema
--------------------------------------------------------
\c hlf_db;

DROP SCHEMA IF EXISTS hlf CASCADE;

CREATE SCHEMA hlf AUTHORIZATION hlf_db_owner;

ALTER SCHEMA hlf OWNER TO hlf_db_owner;

SET SEARCH_PATH TO hlf;

--------------------------------------------------------
-- BC_BLOCK
--------------------------------------------------------
CREATE TABLE BC_BLOCK (
BLOCK              INT    	        PRIMARY KEY,
CHANNEL            VARCHAR(30)  	NOT NULL,
PEER               VARCHAR(100) 	NOT NULL,
TIMESTAMP          TIMESTAMP        NOT NULL,
CONSUMING_TIME     TIMESTAMP        NOT NULL,
VALID_SYSTEM_TXS   INT,
INVALID_SYSTEM_TXS INT,
VALID_USER_TXS     INT,
INVALID_USER_TXS   INT
);

ALTER TABLE BC_BLOCK ADD CONSTRAINT CHECK_BLOCK_TIMESTAMP CHECK
(
TIMESTAMP < CONSUMING_TIME
);

--------------------------------------------------------
-- BC_VALID_TX
--------------------------------------------------------
CREATE TABLE BC_VALID_TX (
BLOCK     	        INT    	        NOT NULL,
TXSEQ               INT             NOT NULL,
TXID      	        VARCHAR(100)    UNIQUE,
ORG_NAME  	        VARCHAR(50)  	NOT NULL,
TIMESTAMP 	        TIMESTAMP   	NOT NULL,
CHAINCODE 	        VARCHAR(20),
FUNCTION  	        VARCHAR(50),
EXCLUDED_WRITE_KEYS INT,
PRIMARY KEY (BLOCK, TXSEQ),
FOREIGN KEY (BLOCK) REFERENCES BC_BLOCK
);

--------------------------------------------------------
-- BC_INVALID_TX
--------------------------------------------------------
CREATE TABLE BC_INVALID_TX (
BLOCK               INT             NOT NULL,
TXSEQ               INT             NOT NULL,
TXID                VARCHAR(100)    UNIQUE,
ORG_NAME            VARCHAR(50)  	NOT NULL,
TIMESTAMP 	        TIMESTAMP      	NOT NULL,
CHAINCODE 	        VARCHAR(20),
FUNCTION  	        VARCHAR(50),
EXCLUDED_WRITE_KEYS INT,
EXCLUDED_READ_KEYS  INT,
ERROR     	        VARCHAR(200) 	NOT NULL,
PRIMARY KEY (BLOCK, TXSEQ),
FOREIGN KEY (BLOCK) REFERENCES BC_BLOCK
);

--------------------------------------------------------
-- BC_VALID_TX_WRITE_SET
--------------------------------------------------------
CREATE TABLE BC_VALID_TX_WRITE_SET (
BLOCK     	INT            NOT NULL,
TXSEQ       INT            NOT NULL,
ITEM        INT            NOT NULL,
KEY         VARCHAR(100)   NOT NULL,
VALUE       VARCHAR(4000),
IS_DELETE   CHAR(1),
PRIMARY KEY (BLOCK, TXSEQ, ITEM),
FOREIGN KEY (BLOCK, TXSEQ) REFERENCES BC_VALID_TX
);

ALTER TABLE BC_VALID_TX_WRITE_SET ADD CONSTRAINT CHECK_VALID_TX_VALUE CHECK
(
(VALUE IS NULL AND IS_DELETE = 'T') OR
(VALUE IS NOT NULL AND IS_DELETE IS NULL)
);

CREATE INDEX BC_VALID_KEY_IDX ON BC_VALID_TX_WRITE_SET(KEY);

--------------------------------------------------------
-- BC_INVALID_TX_SET
--------------------------------------------------------
CREATE TABLE BC_INVALID_TX_SET (
BLOCK     	INT    	        NOT NULL,
TXSEQ       INT             NOT NULL,
TYPE        CHAR(1)        	NOT NULL,
ITEM        INT             NOT NULL,
KEY         VARCHAR(100)  	NOT NULL,
VERSION     VARCHAR(10),
VALUE       VARCHAR(4000),
IS_DELETE   CHAR(1),
PRIMARY KEY (BLOCK, TXSEQ, ITEM, TYPE),
FOREIGN KEY (BLOCK, TXSEQ) REFERENCES BC_INVALID_TX
);

CREATE INDEX BC_INVALID_KEY_IDX ON BC_INVALID_TX_SET(KEY);
