--------------------------------------------------------
--  DDL for Package WSMPVERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPVERS" AUTHID CURRENT_USER AS
/* $Header: WSMVERSS.pls 115.0 2002/11/27 01:38:56 bbalakum noship $ */
function get_osfm_release_version RETURN VARCHAR2;
END WSMPVERS;

 

/
