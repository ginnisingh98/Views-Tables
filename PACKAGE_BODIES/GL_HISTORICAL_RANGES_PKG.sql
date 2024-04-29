--------------------------------------------------------
--  DDL for Package Body GL_HISTORICAL_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_HISTORICAL_RANGES_PKG" as
/* $Header: glirtrgb.pls 120.2 2005/05/05 01:21:32 kvora ship $ */


  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR c_getid IS
      SELECT GL_HISTORICAL_RATE_RANGES_S.NEXTVAL
      FROM   dual;
    id number;

  BEGIN
    OPEN  c_getid;
    FETCH c_getid INTO id;

    IF c_getid%FOUND THEN
      CLOSE c_getid;
      RETURN( id );
    ELSE
      CLOSE c_getid;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_HISTORICAL_RATE_RANGES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_HISTORICAL_RANGES_PKG.get_unique_id');
      RAISE;

  END get_unique_id;


END GL_HISTORICAL_RANGES_PKG;

/
