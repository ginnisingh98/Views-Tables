--------------------------------------------------------
--  DDL for Package Body POS_SUP_PROF_PRG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUP_PROF_PRG_GRP" as
/* $Header: POSSPPGB.pls 120.1 2006/01/10 13:37:40 bitang noship $ */

procedure handle_purge(x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
   -- delete pending suppliser user registration of vendors no longer in ap_suppliers table
   DELETE FROM fnd_registrations
     WHERE registration_id IN
     (SELECT registration_id
      FROM fnd_registration_details frd
      WHERE field_name = 'Supplier Number'
      AND not exists
      (select vendor_id from ap_suppliers where vendor_id= frd.field_value_number) )
     AND registration_status <> 'APPROVED';

   -- Remove all the registrations details that dont have a parent
   DELETE FROM fnd_registration_details
     WHERE registration_id not IN
     (SELECT registration_id
      FROM fnd_registrations
      );

   x_return_status := fnd_api.g_ret_sts_success ;

END handle_purge;

END POS_SUP_PROF_PRG_GRP;

/
