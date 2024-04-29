--------------------------------------------------------
--  DDL for Package Body PA_AR_INST_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AR_INST_CLIENT_EXTN" AS
/* $Header: PAVARICB.pls 120.3 2005/08/19 17:06:58 mwasowic noship $ */
      PROCEDURE client_extn_driver
          (  p_ar_inst_mode             IN    VARCHAR2,
             x_ar_inst_mode		OUT   NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
 l_ar_inst_mode     VARCHAR2(1);
BEGIN
   pa_override_ar_inst.get_installation_mode(p_ar_inst_mode,l_ar_inst_mode);

    -- if the ar install mode is I then no changes
    -- else assign S to ar install flag

   IF NVL(l_ar_inst_mode,'S') <>   'I'
   then
      x_ar_inst_mode := 'S';
   ELSE
      x_ar_inst_mode := 'I';
   END IF;
EXCEPTION
WHEN OTHERS THEN

    /* ATG Changes */
     x_ar_inst_mode := null;

	RAISE;

END client_extn_driver;

end pa_ar_inst_client_extn;

/
