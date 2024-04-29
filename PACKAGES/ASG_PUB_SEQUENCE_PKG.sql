--------------------------------------------------------
--  DDL for Package ASG_PUB_SEQUENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_PUB_SEQUENCE_PKG" AUTHID CURRENT_USER as
/* $Header: asgpseqs.pls 120.1 2005/08/12 02:54:36 saradhak noship $ */

--
--  NAME
--    ASG_PUB_SEQUENCE
--
--  PURPOSE
--
-- HISTORY
--  JUN 03, 2002  ytian   changed _id pk type to varchar2.
--  MAR 11, 2002  ytian   added insert_row, update_row, upload_row
--  Mar 08, 2002  yazhang add Get_Next_Client_Number function
--  Mar 07, 2002  ytian created

/* get the next client_number for user.*/
Function Get_Next_Client_Number return INTEGER;

/* get the clientnumber */
Function getCLIENT_NUMBER(X_CLIENTID IN Varchar2) RETURN number;

/* Get me next value */
Function getNEXT_VALUE RETURN number;

/* Get me start value */
Function getSTART_VALUE(X_CLIENT_NUMBER number, X_TABLE_NAME varchar2,
 X_PRIMARY_KEY varchar2, X_START_MOBILE varchar2 ) RETURN number;

procedure insert_row (
  x_SEQUENCE_ID in VARCHAR2,
  x_SEQUENCE_NAME in VARCHAR2,
  x_PUBLICATION_ID in VARCHAR2,
  x_B_SCHEMA in VARCHAR2,
  x_B_TABLE in VARCHAR2,
  x_B_COLUMN in VARCHAR2,
  x_MOBILE_VALUE in VARCHAR2,
  x_ENABLED    in VARCHAR2,
  x_STATUS     in VARCHAR2,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER );

procedure update_row (
  x_SEQUENCE_ID in VARCHAR2,
  x_SEQUENCE_NAME in VARCHAR2,
  x_PUBLICATION_ID in VARCHAR2,
  x_B_SCHEMA in VARCHAR2,
  x_B_TABLE in VARCHAR2,
  x_B_COLUMN in VARCHAR2,
  x_MOBILE_VALUE in VARCHAR2,
  x_ENABLED    in VARCHAR2,
  x_STATUS     in VARCHAR2,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER );

procedure load_row (
  x_SEQUENCE_ID in VARCHAR2,
  x_SEQUENCE_NAME in VARCHAR2,
  x_PUBLICATION_ID in VARCHAR2,
  x_B_SCHEMA in VARCHAR2,
  x_B_TABLE in VARCHAR2,
  x_B_COLUMN in VARCHAR2,
  x_MOBILE_VALUE in VARCHAR2,
  x_ENABLED    in VARCHAR2,
  x_STATUS     in VARCHAR2,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2);

END ASG_PUB_SEQUENCE_PKG;



 

/
