--------------------------------------------------------
--  DDL for Package Body GL_FEEDER_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FEEDER_INFO_PKG" AS
/* $Header: glapfpb.pls 120.4.12010000.4 2009/12/08 10:30:16 degoel ship $ */

  PROCEDURE get_enc_id_and_name( x_req_id   IN OUT NOCOPY NUMBER,
                                 x_po_id    IN OUT NOCOPY NUMBER,
                                 x_req_name IN OUT NOCOPY VARCHAR2,
                                 x_po_name  IN OUT NOCOPY VARCHAR2,
                                 x_oth_name IN OUT NOCOPY VARCHAR2) IS

    CURSOR c_req IS
       	 SELECT types.encumbrance_type_id, lpad(lkp.meaning, 20)
         FROM   gl_lookups lkp, gl_encumbrance_types types
         WHERE  lkp.lookup_type='LITERAL'
         and types.encumbrance_type_key = 'Commitment'
	 and upper(lkp.lookup_code) = UPPER(types.encumbrance_type_key);

    CURSOR c_po IS
	 SELECT types.encumbrance_type_id, lpad(lkp.meaning, 20)
         FROM   gl_lookups lkp, gl_encumbrance_types types
         WHERE  lkp.lookup_type='LITERAL'
         and types.encumbrance_type_key = 'Obligation'
	 and upper(lkp.lookup_code) = UPPER(types.encumbrance_type_key);

    CURSOR c_oth IS
      SELECT lpad(meaning, 20)
      FROM   gl_lookups
      WHERE  lookup_type='LITERAL'
      AND    lookup_code='OTHER';

  BEGIN
    OPEN  c_req;
    FETCH c_req  INTO x_req_id, x_req_name;
    CLOSE c_req;

    OPEN  c_po;
    FETCH c_po  INTO x_po_id, x_po_name;
    CLOSE c_po;

    OPEN  c_oth;
    FETCH c_oth  INTO x_oth_name;
    CLOSE c_oth;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_feeder_info_pkg.get_enc_id_and_name
');
      RAISE;
  END get_enc_id_and_name;

END gl_feeder_info_pkg;

/
