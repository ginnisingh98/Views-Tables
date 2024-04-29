--------------------------------------------------------
--  DDL for Package AD_TABLESPACE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_TABLESPACE_UTILS" AUTHID CURRENT_USER AS
  -- $Header: adsputls.pls 120.0 2005/05/25 12:05:00 appldev noship $

procedure get_mview_tablespaces
           (X_data_tablespace  out nocopy varchar2,
            X_index_tablespace out nocopy varchar2);

END;

 

/
