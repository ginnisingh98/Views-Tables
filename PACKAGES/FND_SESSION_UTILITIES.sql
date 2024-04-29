--------------------------------------------------------
--  DDL for Package FND_SESSION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SESSION_UTILITIES" AUTHID CURRENT_USER as
/* $Header: AFICXSUS.pls 115.2 2003/12/05 21:37:00 nlbarlow noship $ */

  function SessionID_to_XSID(p_session_id in number) return varchar2;

  function XSID_to_SessionID(p_XSID in varchar2) return number;

  function TransactionID_to_XTID(p_transaction_id in number) return varchar2;

  function XTID_to_TransactionID(p_XTID in varchar2) return number;

  function MAC(p_source in varchar2,
               p_session_id in number) return varchar2;

end FND_SESSION_UTILITIES;

 

/
