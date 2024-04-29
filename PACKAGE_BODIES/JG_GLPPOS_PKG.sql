--------------------------------------------------------
--  DDL for Package Body JG_GLPPOS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_GLPPOS_PKG" as
/* $Header: jgzzposb.pls 120.3.12010000.2 2009/12/04 10:45:23 rshergil ship $ */

PROCEDURE glphk (posting_run_id IN NUMBER) is
  retcode                      NUMBER        := 0;
  errmsg                       VARCHAR2(100) := '';
  cutoff_error                 EXCEPTION;
  sequence_error               EXCEPTION;
  v_set_of_books_id            NUMBER        := 0;
  v_install_flag               char(1);
  v_global_attribute_category  VARCHAR2(150);
 /* commented for June 24 th release bug by shijain, uncomment later
  v_country_attribute_category VARCHAR2(150) := 'JE.GR.GLXSTBKS.BOOKS'; -- Greece
*/
BEGIN

  v_set_of_books_id := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
  --
  -- Determine what country we're in by looking at the
  -- set of books global_attribute_category
  --

/* commented out bug 5194263 */
  /* select global_attribute_category
  into   v_global_attribute_category
  from   gl_sets_of_books
  where  set_of_books_id = v_set_of_books_id;
*/
select 'Y'
into v_install_flag
from dual
where exists
(select 'Y'                          --
   from fnd_product_installations    -- Check if European Localization(7002)
  where application_id = 7002        -- is installed.
   and  db_status = 'I'              --
   and  status = 'I'                 --
 intersect
 select 'Y'                          --
 from fnd_product_installations      -- Check if Regional Localization(7003)
 where application_id = 7003         -- is installed.
   and db_status = 'I'               --
   and status = 'I' );                 --

 IF v_install_flag ='Y' THEN

  /*IF (v_global_attribute_category = v_country_attribute_category) THEN*/
     --
     -- Check the cutoff rules
     --
 /* commented for June 24 th release bug by shijain, uncomment later*/
/* uncommented bug 5194263 */
   JE_GR_STATUTORY.gl_cutoff(posting_run_id, retcode, errmsg);
     IF (retcode = -1) THEN
       raise cutoff_error;
     END IF;

     --
     -- Check the sequencing
     --
 /* commented for June 24 th release bug by shijain, uncomment later
     JE_GR_STATUTORY.gl_sequence(posting_run_id, retcode, errmsg);
     IF (retcode < 0) THEN
       raise sequence_error;
     END IF;
*/
  END IF;
--END IF;
EXCEPTION
  WHEN cutoff_error THEN
    FND_MESSAGE.set_name ('GL', 'GL_PLL_ROUTINE_ERROR');
    FND_MESSAGE.set_token('ROUTINE', 'JE_GR_STATUTORY.GL_CUTOFF');
-- bug 8722315    APP_EXCEPTION.raise_exception;
  WHEN sequence_error THEN
    FND_MESSAGE.set_name ('GL', 'GL_PLL_ROUTINE_ERROR');
    FND_MESSAGE.set_token('ROUTINE', 'JE_GR_STATUTORY.GL_SEQUENCE');
    APP_EXCEPTION.raise_exception;
  WHEN others THEN
    FND_MESSAGE.set_name ('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.set_token('ERRNO', sqlcode);
    FND_MESSAGE.set_token('REASON', substr(sqlerrm, 1, 80));
    FND_MESSAGE.set_token('ROUTINE', 'GL_GLPPOS_PKH.GLPHK');
    APP_EXCEPTION.raise_exception;
END;

END JG_GLPPOS_PKG;

/
