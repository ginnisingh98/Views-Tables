--------------------------------------------------------
--  DDL for Package ASG_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_RESP_PKG" AUTHID CURRENT_USER as
/* $Header: asgresps.pls 120.1 2005/08/12 02:57:47 saradhak noship $ */

--
--    Table handler for ASG_PUB_RESPONSIBILITY table.
--
-- HISTORY
-- JUN  03  2002   ytian changed _ID pk type to varchar2.
-- MAR. 11, 2002   ytian Created.
--

procedure insert_row (
  x_PUB_ID in VARCHAR2,
  x_RESPONSIBILITY_ID in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER);


procedure update_row (
   x_PUB_ID in VARCHAR2,
  x_RESPONSIBILITY_ID in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER);


procedure load_row (
  x_PUB_ID in VARCHAR2,
  x_RESPONSIBILITY_ID in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2);

END ASG_RESP_PKG;

 

/
