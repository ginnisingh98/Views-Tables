--------------------------------------------------------
--  DDL for Package FND_OBIEE_I18N
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OBIEE_I18N" AUTHID CURRENT_USER as
/* $Header: AFOBIEES.pls 120.0.12010000.1 2009/08/28 10:37:51 raghosh noship $ */

  function obiee_convert_langcode (from_type varchar2, to_type varchar2, lang_code varchar2) return varchar2;

  function obiee_convert_language (from_type varchar2, to_type varchar2, lang varchar2) return varchar2;

  function obiee_session_langcode return varchar2;

  function obiee_session_locale return varchar2;

  function oracle_installed_langcode (lang varchar2) return varchar2;

  function oracle_installed_language (lang varchar2) return varchar2;

end fnd_obiee_i18n;

/
