--------------------------------------------------------
--  DDL for Package Body GMFARUPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMFARUPD" AS
/* $Header: gmfarupb.pls 120.2 2005/09/20 13:02:24 rseshadr noship $ */
  PROCEDURE glarupd (
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY NUMBER,
    p_co_code		IN  VARCHAR2,
    pf_orgn_code	IN  VARCHAR2 DEFAULT NULL,
    pt_orgn_code	IN  VARCHAR2 DEFAULT NULL,
    pf_bol_no		IN  VARCHAR2 DEFAULT NULL,
    pt_bol_no		IN  VARCHAR2 DEFAULT NULL)
  AS

    l_retval BOOLEAN;

  BEGIN

    retcode := 3;
    errbuf := 'This program is obsolete';
    l_retval := fnd_concurrent.set_completion_status(
                  'ERROR','This program is obsolete');

    RETURN;

  END glarupd;


END GMFARUPD;

/
