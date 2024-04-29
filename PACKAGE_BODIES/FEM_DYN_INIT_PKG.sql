--------------------------------------------------------
--  DDL for Package Body FEM_DYN_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DYN_INIT_PKG" AS
/* $Header: femdyninit.plb 120.0 2008/01/10 12:35:45 hakumar noship $ */


  PROCEDURE main( x_errbuf	OUT NOCOPY VARCHAR2,
                  x_retcode	OUT NOCOPY VARCHAR2) IS

    l_ret_status  BOOLEAN;

  BEGIN

    fnd_file.put_line(fnd_file.log, 'Starting Dynamic Initialization');

    fnd_file.put_line(fnd_file.log, 'Manipulating XML Publisher Data Templates');
    FEM_DATA_TEMPLATE_UTIL_PKG.replace_dt_proc(x_errbuf, x_retcode);

    fnd_file.put_line(fnd_file.log, 'Completed Dynamic Initialization');

    x_retcode := '0';

  EXCEPTION
     WHEN OTHERS THEN
      x_errbuf := substr( SQLERRM, 1, 2000);
      x_retcode := '2';
      fnd_file.put_line(fnd_file.log, 'Fatal Error Occurred : ' || SQLERRM);
      l_ret_status         :=      fnd_concurrent.set_completion_status(
                                                status  =>      'ERROR',
                                                message =>      NULL);

  END main;


END FEM_DYN_INIT_PKG;

/
