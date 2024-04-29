--------------------------------------------------------
--  DDL for Package FF_WRAPPER_SUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_WRAPPER_SUP_PKG" AUTHID CURRENT_USER as
/*  $Header: ffwrpsup.pkh 115.1 2004/06/16 06:40:36 arashid noship $ */
--
--  Create FFW package body. This is for the FF compiler.
--
procedure create_ffw_body
(p_wrapper_pkg_name  in varchar2
,p_standard_pkg_name in varchar2
,p_keep_package      in varchar2 default 'N'
);
--
--  Create the FF wrapper package.
--
procedure create_wrapper;
--
-- Concurrent Processing Version.
--
procedure create_wrapper
(errbuf  out nocopy varchar2
,retcode out nocopy number
);
end ff_wrapper_sup_pkg;

 

/
