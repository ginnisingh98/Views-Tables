--------------------------------------------------------
--  DDL for Package Body GL_CONC_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CONC_CONTROL_PKG" AS
/*  $Header: glicurcb.pls 120.2 2003/04/24 01:28:00 djogg ship $ */


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE insert_conc_ledger(
    x_ledger_id             NUMBER,
    x_last_update_date      DATE,
    x_last_updated_by       NUMBER,
    x_creation_date         DATE,
    x_created_by            NUMBER,
    x_last_update_login     NUMBER )  IS

  BEGIN
    LOCK TABLE GL_CONCURRENCY_CONTROL IN SHARE UPDATE MODE;
    INSERT INTO gl_concurrency_control(
      concurrency_class,
      concurrency_entity_name,
      concurrency_entity_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login )
    SELECT
      lk.lookup_code,
      'LEDGER',
      to_char( x_ledger_id ),
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login
    FROM
      gl_lookups lk
    WHERE
      lk.lookup_type = 'CONCURRENCY_LEDGER'
      AND NOT EXISTS(
        SELECT	1
        FROM	gl_concurrency_control cc
        WHERE	cc.concurrency_class = lk.lookup_code
        AND	cc.concurrency_entity_name = 'LEDGER'
        AND	cc.concurrency_entity_id = to_char( x_ledger_id ) );

    INSERT INTO gl_concurrency_control(
      concurrency_class,
      concurrency_entity_name,
      concurrency_entity_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login )
    SELECT
      'FETCH_TEMPLATE_ORDER',
      'ASC',
      to_char( x_ledger_id ),
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login
    FROM
      dual
    WHERE
      NOT EXISTS(
        SELECT  1
        FROM    gl_concurrency_control cc
        WHERE   cc.concurrency_class = 'FETCH_TEMPLATE_ORDER'
        AND     cc.concurrency_entity_id = to_char( x_ledger_id ) );

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_CONC_CONTROL_PKG.insert_conc_ledger');
      RAISE;

  END insert_conc_ledger;

-- ************************************************************************


  PROCEDURE insert_conc_subs(
    x_subsidiary_id		NUMBER,
    x_last_update_date		DATE,
    x_last_updated_by		NUMBER,
    x_creation_date		DATE,
    x_created_by		NUMBER,
    x_last_update_login		NUMBER )  IS

  BEGIN
    LOCK TABLE GL_CONCURRENCY_CONTROL IN SHARE UPDATE MODE;
    INSERT INTO gl_concurrency_control(
      concurrency_class,
      concurrency_entity_name,
      concurrency_entity_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login )
    SELECT
      lk.lookup_code,
      'SUBSIDIARY',
      to_char( x_subsidiary_id ),
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login
    FROM
      gl_lookups lk
    WHERE
      lk.lookup_type = 'CONCURRENCY_SUBS'
      AND NOT EXISTS(
        SELECT	1
        FROM	gl_concurrency_control cc
        WHERE	cc.concurrency_class = lk.lookup_code
        AND	cc.concurrency_entity_name = 'SUBSIDIARY'
        AND	cc.concurrency_entity_id = to_char( x_subsidiary_id ) );


  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_CONC_CONTROL_PKG.insert_conc_subs');
      RAISE;

  END insert_conc_subs;

-- ************************************************************************

END GL_CONC_CONTROL_PKG;

/
