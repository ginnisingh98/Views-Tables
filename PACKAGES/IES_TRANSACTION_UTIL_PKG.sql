--------------------------------------------------------
--  DDL for Package IES_TRANSACTION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_TRANSACTION_UTIL_PKG" AUTHID CURRENT_USER AS
  /* $Header: iestrns.pls 115.3 2003/05/02 22:54:06 prkotha noship $ */

  FUNCTION  getRestartXMLData(p_transaction_id IN NUMBER) RETURN CLOB;


  PROCEDURE Update_Transaction(p_transaction_Id in number,
                               p_status IN NUMBER,
                               p_restart_clob IN CLOB,
                               p_user_id IN NUMBER);

  PROCEDURE Update_Transaction(p_transaction_Id in number);

  FUNCTION  insert_transaction(p_user_Id IN NUMBER,
                               p_dscript_Id IN NUMBER) RETURN NUMBER;


  PROCEDURE getTemporaryCLOB (x_clob OUT NOCOPY  CLOB);

END ies_transaction_util_pkg;

 

/
