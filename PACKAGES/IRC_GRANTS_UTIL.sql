--------------------------------------------------------
--  DDL for Package IRC_GRANTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_GRANTS_UTIL" AUTHID CURRENT_USER AS
/* $Header: irgntutl.pkh 120.0.12000000.1 2007/01/17 02:09:59 appldev noship $ */

-- ----------------------------------------------------------------------------
-- |------------------------< create_grants>----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description : This package declares functions used in
--               creating Grants for users who have given responsibility
--
--
procedure create_grants(
  errbuf    OUT NOCOPY VARCHAR2
 ,retcode   OUT NOCOPY NUMBER
 ,p_resp_key IN VARCHAR2
 ,p_resp_appl_name IN VARCHAR2
 ,p_permission_set IN VARCHAR2);
--
end irc_grants_util;

 

/
