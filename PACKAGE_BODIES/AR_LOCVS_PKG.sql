--------------------------------------------------------
--  DDL for Package Body AR_LOCVS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_LOCVS_PKG" AS
/* $Header: ARLOCVSB.pls 120.5 2005/10/07 11:11:48 mparihar ship $ */

-- MOAC
-- X_ORG_ID is added as new parameter
-- when called from Store Online x_org_id is null.
-- Refer to bug 1791904.
-- At the moment, x_org_id parameter is not added in
-- AR_LOCATION_VALUE_V_PKG due to the dependency.
--
PROCEDURE INSERT_ROW (
  X_ROWID 			in out NOCOPY VARCHAR2,
  X_LOCATION_SEGMENT_ID 	in NUMBER,
  X_LOCATION_VALUE_ACCOUNT_ID 	in NUMBER,
  X_LOCATION_STRUCTURE_ID 	in NUMBER,
  X_LOCATION_SEGMENT_QUALIFIER 	in VARCHAR2,
  X_LOCATION_SEGMENT_VALUE 	in VARCHAR2,
  X_LOCATION_SEGMENT_DESCRIPTION in VARCHAR2,
  X_LOCATION_SEGMENT_USER_VALUE in VARCHAR2,
  X_PARENT_SEGMENT_ID  		in NUMBER,
  X_TAX_ACCOUNT_CCID 		in NUMBER,
  X_INTERIM_TAX_CCID 		in NUMBER,
  X_ADJ_CCID 			in NUMBER,
  X_EDISC_CCID 			in NUMBER,
  X_UNEDISC_CCID 		in NUMBER,
  X_FINCHRG_CCID 		in NUMBER,
  X_ADJ_NON_REC_TAX_CCID 	in NUMBER,
  X_EDISC_NON_REC_TAX_CCID 	in NUMBER,
  X_UNEDISC_NON_REC_TAX_CCID 	in NUMBER,
  X_FINCHRG_NON_REC_TAX_CCID 	in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
  X_CREATION_DATE 		in DATE,
  X_CREATED_BY 			in NUMBER,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER,
  X_REQUEST_ID 			in NUMBER,
  X_PROGRAM_APPLICATION_ID 	in NUMBER,
  X_PROGRAM_ID 			in NUMBER,
  X_PROGRAM_UPDATE_DATE 	in DATE,
  X_ORG_ID                      in NUMBER
) is

cursor C is select ROWID from AR_LOCATION_VALUES_OLD
where LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID;

/*-------------------------------------------------------------------------+
| PRIVATE CURSOR                                                           |
|   ar_location_tax_account_c                                              |
|                                                                          |
| DESCRIPTION                                                              |
|   Return the tax account id from ar_vat_tax where tax type is LOCATION   |
|   This cursor selects from multi-org table AR_VAT_TAX_ALL using C_ORG_ID |
+-------------------------------------------------------------------------*/

CURSOR ar_location_tax_account_c (c_org_id in number) IS
select
        tax_account_id,
        INTERIM_TAX_CCID,
        ADJ_CCID,
        EDISC_CCID,
        UNEDISC_CCID,
        FINCHRG_CCID,
        ADJ_NON_REC_TAX_CCID,
        EDISC_NON_REC_TAX_CCID,
        UNEDISC_NON_REC_TAX_CCID,
        FINCHRG_NON_REC_TAX_CCID
from ar_vat_tax_all vat
where tax_type='LOCATION'
and   org_id = c_org_id
and   trunc(sysdate) between start_date and nvl(end_date, trunc(sysdate));


/*-------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   ar_location_accounts_s_c                                              |
|                                                                         |
| DESCRIPTION                                                             |
|    Return the next value from the sequence AR_LOCATION_ACCOUNTS_S       |
| RETURNS                                                                 |
|    Sequence ID + large constant used for debugging                      |
+-------------------------------------------------------------------------*/
CURSOR ar_location_accounts_s_c IS
select ar_location_accounts_s.nextval + arp_standard.sequence_offset
from dual;

/*------------------------------------------------------------------------+
| PRIVATE CURSOR                                                          |
|   organization_id_c                                                     |
|                                                                         |
| DESCRIPTION                                                             |
|    Used to select distinct ORG_ID from AR_SYSTEM_PARAMETERS_ALL         |
|    to create one record per ORG_ID for a new location_id in             |
|    AR_LOCATION_ACCOUNTS_ALL                                             |
| RETURNS                                                                 |
|    Returns distinct ORG_ID from AR_SYSTEM_PARAMETERS_ALL                |
+-------------------------------------------------------------------------*/

CURSOR organization_id_c is
select nvl(org_id, -99), location_structure_id
from   ar_system_parameters_all
where  nvl(org_id, -99) not in (-3113, -3114)
and    set_of_books_id <> -1;

  l_location_value_account_id     number;
  location_tax_account            number;
  l_INTERIM_TAX_CCID              NUMBER;
  l_ADJ_CCID                      NUMBER;
  l_EDISC_CCID                    NUMBER;
  l_UNEDISC_CCID                  NUMBER;
  l_FINCHRG_CCID                  NUMBER;
  l_ADJ_NON_REC_TAX_CCID          NUMBER;
  l_EDISC_NON_REC_TAX_CCID        NUMBER;
  l_UNEDISC_NON_REC_TAX_CCID      NUMBER;
  l_FINCHRG_NON_REC_TAX_CCID      NUMBER;

  type num_tab is table of number index by binary_integer;
  type date_tab is table of date index by binary_integer;
  org_id_tab num_tab;
  loc_structure_id_tab num_tab;
  location_account_id_tab      num_tab;
  location_segment_id_tab      num_tab;
  tax_account_ccid_tab         num_tab;
  interim_tax_ccid_tab         num_tab;
  adj_ccid_tab                 num_tab;
  edisc_ccid_tab               num_tab;
  unedisc_ccid_tab             num_tab;
  finchrg_ccid_tab             num_tab;
  adj_non_rec_tax_ccid_tab     num_tab;
  edisc_non_rec_tax_ccid_tab   num_tab;
  unedisc_non_rec_tax_ccid_tab num_tab;
  finchrg_non_rec_tax_ccid_tab num_tab;
  created_by_tab               num_tab;
  creation_date_tab            date_tab;
  last_updated_by_tab          num_tab;
  last_update_date_tab         date_tab;
  request_id_tab               num_tab;
  program_application_id_tab   num_tab;
  program_id_tab               num_tab;
  program_update_date_tab      date_tab;
  last_update_login_tab        num_tab;
  organization_id_tab          num_tab;
  -- MOAC: X_ORG_ID is passed from UI.
  -- X_ORG_ID                     NUMBER;

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
begin

  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.insert_row(+) ');
    arp_util_tax.debug(' Before inserting into AR_LOCATION_VALUES_OLD ');
  END IF;

  -- MOAC
  -- need to select org_id
  -- if x_org_id is null
  -- which is the case where the ar_locvs_pkg is called from
  -- store online.

  -- MOAC
  -- org_id is added
  insert into AR_LOCATION_VALUES_OLD (
  LOCATION_SEGMENT_ID,
  LOCATION_STRUCTURE_ID,
  LOCATION_SEGMENT_QUALIFIER,
  LOCATION_SEGMENT_VALUE,
  LOCATION_SEGMENT_DESCRIPTION,
  LOCATION_SEGMENT_USER_VALUE,
  PARENT_SEGMENT_ID,
  ATTRIBUTE_CATEGORY,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  REQUEST_ID,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID,
  PROGRAM_UPDATE_DATE,
  ORG_ID
  ) values (
  X_LOCATION_SEGMENT_ID,
  X_LOCATION_STRUCTURE_ID,
  X_LOCATION_SEGMENT_QUALIFIER,
  X_LOCATION_SEGMENT_VALUE,
  X_LOCATION_SEGMENT_DESCRIPTION,
  X_LOCATION_SEGMENT_USER_VALUE,
  X_PARENT_SEGMENT_ID,
  X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1,
  X_ATTRIBUTE2,
  X_ATTRIBUTE3,
  X_ATTRIBUTE4,
  X_ATTRIBUTE5,
  X_ATTRIBUTE6,
  X_ATTRIBUTE7,
  X_ATTRIBUTE8,
  X_ATTRIBUTE9,
  X_ATTRIBUTE10,
  X_ATTRIBUTE11,
  X_ATTRIBUTE12,
  X_ATTRIBUTE13,
  X_ATTRIBUTE14,
  X_ATTRIBUTE15,
  X_CREATION_DATE,
  X_CREATED_BY,
  X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN,
  X_REQUEST_ID,
  X_PROGRAM_APPLICATION_ID,
  X_PROGRAM_ID,
  X_PROGRAM_UPDATE_DATE,
  X_ORG_ID
  );
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' After inserting into AR_LOCATION_VALUES_OLD ');
  END IF;

  /* MOAC
     Commented out as X_ORG_ID is passed from UI as part of the parameter.
  select NVL (TO_NUMBER (DECODE (SUBSTRB (USERENV ('CLIENT_INFO'),1,1), ' ',NULL,
                                SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    into X_ORG_ID
    from dual;
  */

/* +----------------------------------------------------------------------------------
  Insert in AR_LOCATION_ACCOUNTS only if the TAX_ACCOUNT_CCID is not null
  we could have the segment qualifier without TAX_ACCOUNT in which case no
  records should be inserted in to this table though we will have to insert
  into AR_LOCATION_VALUES_OLD
  +-----------------------------------------------------------------------------------*/


if  X_TAX_ACCOUNT_CCID is not null then
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' Before inserting into AR_LOCATION_ACCOUNTS ');
  END IF;
  insert into AR_LOCATION_ACCOUNTS_ALL (
  LOCATION_VALUE_ACCOUNT_ID,
  LOCATION_SEGMENT_ID,
  TAX_ACCOUNT_CCID,
  INTERIM_TAX_CCID,
  ADJ_CCID,
  EDISC_CCID,
  UNEDISC_CCID,
  FINCHRG_CCID,
  ADJ_NON_REC_TAX_CCID,
  EDISC_NON_REC_TAX_CCID,
  UNEDISC_NON_REC_TAX_CCID,
  FINCHRG_NON_REC_TAX_CCID,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  REQUEST_ID,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID,
  PROGRAM_UPDATE_DATE,
  ORG_ID
  )values
(
  X_LOCATION_VALUE_ACCOUNT_ID,
  X_LOCATION_SEGMENT_ID,
  X_TAX_ACCOUNT_CCID,
  X_INTERIM_TAX_CCID,
  X_ADJ_CCID,
  X_EDISC_CCID,
  X_UNEDISC_CCID,
  X_FINCHRG_CCID,
  X_ADJ_NON_REC_TAX_CCID,
  X_EDISC_NON_REC_TAX_CCID,
  X_UNEDISC_NON_REC_TAX_CCID,
  X_FINCHRG_NON_REC_TAX_CCID,
  X_CREATION_DATE,
  X_CREATED_BY,
  X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN,
  X_REQUEST_ID,
  X_PROGRAM_APPLICATION_ID,
  X_PROGRAM_ID,
  X_PROGRAM_UPDATE_DATE,
  X_ORG_ID);
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' After inserting into AR_LOCATION_ACCOUNTS ');
  END IF;

   org_id_tab.delete;
   loc_structure_id_tab.delete;
   location_account_id_tab.delete;
   location_segment_id_tab.delete;
   tax_account_ccid_tab.delete;
   interim_tax_ccid_tab.delete;
   adj_ccid_tab.delete;
   edisc_ccid_tab.delete;
   unedisc_ccid_tab.delete;
   finchrg_ccid_tab.delete;
   adj_non_rec_tax_ccid_tab.delete;
   edisc_non_rec_tax_ccid_tab.delete;
   unedisc_non_rec_tax_ccid_tab.delete;
   finchrg_non_rec_tax_ccid_tab.delete;
   created_by_tab.delete;
   creation_date_tab.delete;
   last_updated_by_tab.delete;
   last_update_date_tab.delete;
   request_id_tab.delete;
   program_application_id_tab.delete;
   program_id_tab.delete;
   program_update_date_tab.delete;
   last_update_login_tab.delete;
   organization_id_tab.delete;


   open organization_id_c ;
   fetch organization_id_c bulk collect into
             org_id_tab, loc_structure_id_tab;
   close organization_id_c ;

/*-------------------------------------------------------------------------+
 |   We insert new records in AR_LOCATION_ACCOUNTS_ALL table               |
 |   One record is created for each ORG_ID                                 |
 |   so that Accounting information in this table is Organization          |
 |   independent and so that location structure can be shared across       |
 |   Organizations.                                                        |
 +-------------------------------------------------------------------------*/


   -- Insert records into ar_location_accounts_all
   for I in 1..org_id_tab.last loop

                      location_tax_account := NULL;
                      l_INTERIM_TAX_CCID := NULL;
                      l_ADJ_CCID := NULL;
                      l_EDISC_CCID := NULL;
                      l_UNEDISC_CCID := NULL;
                      l_FINCHRG_CCID := NULL;
                      l_ADJ_NON_REC_TAX_CCID := NULL;
                      l_EDISC_NON_REC_TAX_CCID := NULL;
                      l_UNEDISC_NON_REC_TAX_CCID := NULL;
                      l_FINCHRG_NON_REC_TAX_CCID := NULL;

          OPEN  ar_location_tax_account_c(org_id_tab(I));
                FETCH ar_location_tax_account_c into
                    location_tax_account,
                      l_INTERIM_TAX_CCID,
                      l_ADJ_CCID,
                      l_EDISC_CCID,
                      l_UNEDISC_CCID,
                      l_FINCHRG_CCID,
                      l_ADJ_NON_REC_TAX_CCID,
                      l_EDISC_NON_REC_TAX_CCID,
                      l_UNEDISC_NON_REC_TAX_CCID,
                      l_FINCHRG_NON_REC_TAX_CCID;
           if ar_location_tax_account_c%NOTFOUND
           then
                     location_tax_account:=arp_standard.sysparm.location_tax_account;
                 end if;
           CLOSE ar_location_tax_account_c;


           OPEN ar_location_accounts_s_c;
           FETCH ar_location_accounts_s_c into
                   l_location_value_account_id;
           CLOSE ar_location_accounts_s_c;

           location_account_id_tab(i)      := l_location_value_account_id;
           location_segment_id_tab(i)      := x_location_segment_id;
           tax_account_ccid_tab(i)         := location_tax_account;
           interim_tax_ccid_tab(i)         := l_INTERIM_TAX_CCID;
           adj_ccid_tab(i)                 := l_ADJ_CCID;
           edisc_ccid_tab(i)               := l_EDISC_CCID;
           unedisc_ccid_tab(i)             := l_UNEDISC_CCID;
           finchrg_ccid_tab(i)             := l_FINCHRG_CCID;
           adj_non_rec_tax_ccid_tab(i)     := l_ADJ_NON_REC_TAX_CCID;
           edisc_non_rec_tax_ccid_tab(i)   := l_EDISC_NON_REC_TAX_CCID;
           unedisc_non_rec_tax_ccid_tab(i) := l_UNEDISC_NON_REC_TAX_CCID;
           finchrg_non_rec_tax_ccid_tab(i) := l_FINCHRG_NON_REC_TAX_CCID;
           created_by_tab(i)               := arp_standard.profile.user_id;
           creation_date_tab(i)            := sysdate;
           last_updated_by_tab(i)          := arp_standard.profile.user_id;
           last_update_date_tab(i)         := sysdate;
           request_id_tab(i)               := arp_standard.PROFILE.request_id;
           program_application_id_tab(i)   :=
           arp_standard.PROFILE.program_application_id;
           program_id_tab(i)               := arp_standard.PROFILE.program_id;
           program_update_date_tab(i)      := sysdate;
           last_update_login_tab(i)        := arp_standard.PROFILE.last_update_login;
           organization_id_tab(i)          := org_id_tab(I);
      end loop;

      for I in 1.. organization_id_tab.last loop

           if organization_id_tab(i) <> X_ORG_ID then

           IF PG_DEBUG = 'Y' THEN
             arp_util_tax.debug('Before inserting into AR_LOCATION_ACCOUNTS ('||to_char(organization_id_tab(i))||')' );
           END IF;
           insert into ar_location_accounts_all
                                 ( location_value_account_id,
                                   location_segment_id,
                                   tax_account_ccid,
                                   interim_tax_ccid,
                                   adj_ccid,
                                   edisc_ccid,
                                   unedisc_ccid,
                                   finchrg_ccid,
                                   adj_non_rec_tax_ccid,
                                   edisc_non_rec_tax_ccid,
                                   unedisc_non_rec_tax_ccid,
                                   finchrg_non_rec_tax_ccid,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   request_id,
                                   program_application_id,
                                   program_id,
                                   program_update_date,
                                   last_update_login,
                                   org_id)
                VALUES
               ( location_account_id_tab(i),
                 location_segment_id_tab(i),
                 tax_account_ccid_tab(i),
                 interim_tax_ccid_tab(i),
                 adj_ccid_tab(i),
                 edisc_ccid_tab(i),
                 unedisc_ccid_tab(i),
                 finchrg_ccid_tab(i),
                 adj_non_rec_tax_ccid_tab(i),
                 edisc_non_rec_tax_ccid_tab(i),
                 unedisc_non_rec_tax_ccid_tab(i),
                 finchrg_non_rec_tax_ccid_tab(i),
                 created_by_tab(i),
                 creation_date_tab(i),
                 last_updated_by_tab(i),
                 last_update_date_tab(i),
                 request_id_tab(i),
                 program_application_id_tab(i),
                 program_id_tab(i),
                 program_update_date_tab(i),
                 last_update_login_tab(i),
                 organization_id_tab(i) );
           IF PG_DEBUG = 'Y' THEN
             arp_util_tax.debug('After inserting into AR_LOCATION_ACCOUNTS ');
           END IF;
    end if;
 end loop;
end if;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.insert_row(-) ');
  END IF;

end INSERT_ROW;

procedure LOCK_ROW (
    X_ROWID 				in out NOCOPY VARCHAR2,
    X_LOCATION_SEGMENT_ID 		in NUMBER,
    X_LOCATION_VALUE_ACCOUNT_ID		in NUMBER,
    X_LOCATION_STRUCTURE_ID 		in NUMBER,
    X_LOCATION_SEGMENT_QUALIFIER 	in VARCHAR2,
    X_LOCATION_SEGMENT_VALUE 		in VARCHAR2,
    X_LOCATION_SEGMENT_DESCRIPTION 	in VARCHAR2,
    X_LOCATION_SEGMENT_USER_VALUE 	in VARCHAR2,
    X_PARENT_SEGMENT_ID  		in NUMBER,
    X_TAX_ACCOUNT_CCID 			in NUMBER,
    X_INTERIM_TAX_CCID 			in NUMBER,
    X_ADJ_CCID 				in NUMBER,
    X_EDISC_CCID 			in NUMBER,
    X_UNEDISC_CCID 			in NUMBER,
    X_FINCHRG_CCID 			in NUMBER,
    X_ADJ_NON_REC_TAX_CCID 		in NUMBER,
    X_EDISC_NON_REC_TAX_CCID 		in NUMBER,
    X_UNEDISC_NON_REC_TAX_CCID 		in NUMBER,
    X_FINCHRG_NON_REC_TAX_CCID 		in NUMBER,
    X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
    X_ATTRIBUTE1 			in VARCHAR2,
    X_ATTRIBUTE2 			in VARCHAR2,
    X_ATTRIBUTE3 			in VARCHAR2,
    X_ATTRIBUTE4 			in VARCHAR2,
    X_ATTRIBUTE5 			in VARCHAR2,
    X_ATTRIBUTE6 			in VARCHAR2,
    X_ATTRIBUTE7 			in VARCHAR2,
    X_ATTRIBUTE8 			in VARCHAR2,
    X_ATTRIBUTE9 			in VARCHAR2,
    X_ATTRIBUTE10 			in VARCHAR2,
    X_ATTRIBUTE11 			in VARCHAR2,
    X_ATTRIBUTE12 			in VARCHAR2,
    X_ATTRIBUTE13 			in VARCHAR2,
    X_ATTRIBUTE14 			in VARCHAR2,
    X_ATTRIBUTE15 			in VARCHAR2,
    X_CREATION_DATE	        	in DATE,
    X_CREATED_BY 			in NUMBER,
    X_LAST_UPDATE_DATE 			in DATE,
    X_LAST_UPDATED_BY 			in NUMBER,
    X_LAST_UPDATE_LOGIN 		in NUMBER,
    X_REQUEST_ID 			in NUMBER,
    X_PROGRAM_APPLICATION_ID 		in NUMBER,
    X_PROGRAM_ID 			in NUMBER,
   X_PROGRAM_UPDATE_DATE 		in DATE
) is
  cursor c is select
      LOCATION_SEGMENT_ID,
      LOCATION_STRUCTURE_ID,
      LOCATION_SEGMENT_QUALIFIER,
      LOCATION_SEGMENT_VALUE,
      LOCATION_SEGMENT_DESCRIPTION,
      LOCATION_SEGMENT_USER_VALUE,
      PARENT_SEGMENT_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
      FROM AR_LOCATION_VALUES_OLD
      WHERE LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID
      -- MOAC
      -- LOCATION_SEGMENT_ID is a unique key. No need for client info.
      -- AND   NVL(ORG_ID,NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
      --       NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
      --       NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',
      --       NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
      FOR UPDATE OF LOCATION_SEGMENT_ID NOWAIT;

  recinfo c%rowtype;

cursor c1  is select
      LOCATION_VALUE_ACCOUNT_ID,
       LOCATION_SEGMENT_ID,
       TAX_ACCOUNT_CCID,
       INTERIM_TAX_CCID,
       ADJ_CCID,
       EDISC_CCID,
       UNEDISC_CCID,
       FINCHRG_CCID,
       ADJ_NON_REC_TAX_CCID,
       EDISC_NON_REC_TAX_CCID,
       UNEDISC_NON_REC_TAX_CCID,
       FINCHRG_NON_REC_TAX_CCID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE
       FROM  AR_LOCATION_ACCOUNTS
       WHERE LOCATION_VALUE_ACCOUNT_ID = X_LOCATION_VALUE_ACCOUNT_ID
       FOR UPDATE OF LOCATION_VALUE_ACCOUNT_ID NOWAIT;

 acctinfo c1%rowtype;
 PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
begin
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.lock_row(+) ');
  END IF;
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' No record found for AR_LOCATION_VALUES_OLD ');
    END IF;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    (recinfo.LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID)
        AND ((recinfo.LOCATION_STRUCTURE_ID  = X_LOCATION_STRUCTURE_ID )
           OR ((recinfo.LOCATION_STRUCTURE_ID is null) AND (X_LOCATION_STRUCTURE_ID  is null)))
        AND ((recinfo.LOCATION_SEGMENT_QUALIFIER  = X_LOCATION_SEGMENT_QUALIFIER )
           OR ((recinfo.LOCATION_SEGMENT_QUALIFIER is null) AND (X_LOCATION_SEGMENT_QUALIFIER  is null)))
        AND ((recinfo.LOCATION_SEGMENT_VALUE  = X_LOCATION_SEGMENT_VALUE )
           OR ((recinfo.LOCATION_SEGMENT_VALUE is null) AND (X_LOCATION_SEGMENT_VALUE is null)))
        AND ((recinfo.LOCATION_SEGMENT_DESCRIPTION  = X_LOCATION_SEGMENT_DESCRIPTION )
           OR ((recinfo.LOCATION_SEGMENT_DESCRIPTION is null) AND (X_LOCATION_SEGMENT_DESCRIPTION is null)))
        AND ((recinfo.LOCATION_SEGMENT_USER_VALUE  = X_LOCATION_SEGMENT_USER_VALUE )
           OR ((recinfo.LOCATION_SEGMENT_USER_VALUE is null) AND (X_LOCATION_SEGMENT_USER_VALUE is null)))
        AND ((recinfo.PARENT_SEGMENT_ID  = X_PARENT_SEGMENT_ID )
           OR ((recinfo.PARENT_SEGMENT_ID is null) AND (X_PARENT_SEGMENT_ID is null)))
        AND ((recinfo.ATTRIBUTE_CATEGORY  = X_ATTRIBUTE_CATEGORY )
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
        AND ((recinfo.ATTRIBUTE1  = X_ATTRIBUTE1 )
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
        AND ((recinfo.ATTRIBUTE2  = X_ATTRIBUTE2 )
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
        AND ((recinfo.ATTRIBUTE3  = X_ATTRIBUTE3 )
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
        AND ((recinfo.ATTRIBUTE4  = X_ATTRIBUTE4 )
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
        AND ((recinfo.ATTRIBUTE5  = X_ATTRIBUTE5 )
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
        AND ((recinfo.ATTRIBUTE6  = X_ATTRIBUTE6 )
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
        AND ((recinfo.ATTRIBUTE7  = X_ATTRIBUTE7 )
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
        AND ((recinfo.ATTRIBUTE8  = X_ATTRIBUTE8 )
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
        AND ((recinfo.ATTRIBUTE9  = X_ATTRIBUTE9 )
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
        AND ((recinfo.ATTRIBUTE10  = X_ATTRIBUTE10 )
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
        AND ((recinfo.ATTRIBUTE11  = X_ATTRIBUTE11 )
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
        AND ((recinfo.ATTRIBUTE12  = X_ATTRIBUTE12 )
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
        AND ((recinfo.ATTRIBUTE13  = X_ATTRIBUTE13 )
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
        AND ((recinfo.ATTRIBUTE14  = X_ATTRIBUTE14 )
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
        AND ((recinfo.ATTRIBUTE15  = X_ATTRIBUTE15 )
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into acctinfo;
  if (c1%notfound) then
     close c1;
--    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
--    Bugfix 1712826: Do not raise exception, because there will be a row
--    in AR_LOCATION_ACCOUNTS only for one out of State/County/CITY
--    app_exception.raise_exception;
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' No record found for AR_LOCATION_ACCOUNTS ');
    END IF;
  else
     close c1;
     if (    (acctinfo.LOCATION_VALUE_ACCOUNT_ID = X_LOCATION_VALUE_ACCOUNT_ID)
          AND ((acctinfo.LOCATION_SEGMENT_ID  = X_LOCATION_SEGMENT_ID )
           OR ((acctinfo.LOCATION_SEGMENT_ID is null) AND (X_LOCATION_SEGMENT_ID  is null)))
           AND ((acctinfo.TAX_ACCOUNT_CCID  = X_TAX_ACCOUNT_CCID )
           OR ((acctinfo.TAX_ACCOUNT_CCID is null) AND (X_TAX_ACCOUNT_CCID  is null)))
            AND ((acctinfo.INTERIM_TAX_CCID  = X_INTERIM_TAX_CCID )
           OR ((acctinfo.INTERIM_TAX_CCID is null) AND (X_INTERIM_TAX_CCID  is null)))
            AND ((acctinfo.ADJ_CCID  = X_ADJ_CCID )
           OR ((acctinfo.ADJ_CCID is null) AND (X_ADJ_CCID is null)))
            AND ((acctinfo.EDISC_CCID  = X_EDISC_CCID)
           OR ((acctinfo.EDISC_CCID is null) AND (X_EDISC_CCID is null)))
            AND ((acctinfo.UNEDISC_CCID  = X_UNEDISC_CCID)
           OR ((acctinfo.UNEDISC_CCID is null) AND (X_UNEDISC_CCID is null)))
            AND ((acctinfo.FINCHRG_CCID  = X_FINCHRG_CCID)
           OR ((acctinfo.FINCHRG_CCID is null) AND (X_FINCHRG_CCID is null)))
            AND ((acctinfo.ADJ_NON_REC_TAX_CCID  = X_ADJ_NON_REC_TAX_CCID)
           OR ((acctinfo.ADJ_NON_REC_TAX_CCID is null) AND (X_ADJ_NON_REC_TAX_CCID is null)))
            AND ((acctinfo.EDISC_NON_REC_TAX_CCID = X_EDISC_NON_REC_TAX_CCID)
           OR ((acctinfo.EDISC_NON_REC_TAX_CCID is null) AND (X_EDISC_NON_REC_TAX_CCID is null)))
          AND ((acctinfo.FINCHRG_NON_REC_TAX_CCID = X_FINCHRG_NON_REC_TAX_CCID)
          OR ((acctinfo.FINCHRG_NON_REC_TAX_CCID is null) AND (X_FINCHRG_NON_REC_TAX_CCID is null)))
	  AND ((acctinfo.CREATION_DATE  = X_CREATION_DATE )
	  OR ((acctinfo.CREATION_DATE is null) AND (X_CREATION_DATE is null)))
	   AND ((acctinfo.CREATED_BY  = X_CREATED_BY )
	  OR ((acctinfo.CREATED_BY is null) AND (X_CREATED_BY is null)))
	  AND ((acctinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
	  OR ((acctinfo.LAST_UPDATE_DATE is null) AND (X_LAST_UPDATE_DATE is null)))
	  AND ((acctinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY )
	  OR ((acctinfo.LAST_UPDATED_BY is null) AND (X_LAST_UPDATED_BY is null)))
	  AND ((acctinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
	  OR ((acctinfo.LAST_UPDATE_LOGIN is null) AND (X_LAST_UPDATE_LOGIN is null)))
	  AND ((acctinfo.REQUEST_ID = X_REQUEST_ID )
	  OR ((acctinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
	  AND ((acctinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID )
	  OR ((acctinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
	  AND ((acctinfo.PROGRAM_ID = X_PROGRAM_ID )
	  OR ((acctinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
	  AND ((acctinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE )
	  OR ((acctinfo.PROGRAM_UPDATE_DATE is null) AND (X_PROGRAM_UPDATE_DATE is null)))

	       ) then
	         null;
	       else
	         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	         app_exception.raise_exception;
     end if;
  end if;  -- c1%notfound

  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.lock_row(-) ');
  END IF;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LOCATION_SEGMENT_ID 	in NUMBER,
  X_LOCATION_VALUE_ACCOUNT_ID 	in NUMBER,
  X_LOCATION_STRUCTURE_ID 	in NUMBER,
  X_LOCATION_SEGMENT_QUALIFIER 	in VARCHAR2,
  X_LOCATION_SEGMENT_VALUE 	in VARCHAR2,
  X_LOCATION_SEGMENT_DESCRIPTION in VARCHAR2,
  X_LOCATION_SEGMENT_USER_VALUE in VARCHAR2,
  X_PARENT_SEGMENT_ID  		in NUMBER,
  X_TAX_ACCOUNT_CCID 		in NUMBER,
  X_INTERIM_TAX_CCID 		in NUMBER,
  X_ADJ_CCID 			in NUMBER,
  X_EDISC_CCID 			in NUMBER,
  X_UNEDISC_CCID 		in NUMBER,
  X_FINCHRG_CCID 		in NUMBER,
  X_ADJ_NON_REC_TAX_CCID 	in NUMBER,
  X_EDISC_NON_REC_TAX_CCID 	in NUMBER,
  X_UNEDISC_NON_REC_TAX_CCID 	in NUMBER,
  X_FINCHRG_NON_REC_TAX_CCID 	in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
  X_CREATION_DATE 		in DATE,
  X_CREATED_BY 			in NUMBER,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER,
  X_REQUEST_ID 			in NUMBER,
  X_PROGRAM_APPLICATION_ID 	in NUMBER,
  X_PROGRAM_ID 			in NUMBER,
  X_PROGRAM_UPDATE_DATE 	in DATE
) is
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
begin
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.update_row(+) ');
  END IF;
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' Before updating AR_LOCATION_VALUES_OLD ');
  END IF;
  /* -- for bug #4561754
  update AR_LOCATION_VALUES set
  LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID,
  LOCATION_STRUCTURE_ID = X_LOCATION_STRUCTURE_ID,
  LOCATION_SEGMENT_QUALIFIER = X_LOCATION_SEGMENT_QUALIFIER,
  LOCATION_SEGMENT_VALUE = X_LOCATION_SEGMENT_VALUE,
  LOCATION_SEGMENT_DESCRIPTION = X_LOCATION_SEGMENT_DESCRIPTION,
  LOCATION_SEGMENT_USER_VALUE = X_LOCATION_SEGMENT_USER_VALUE ,
  PARENT_SEGMENT_ID = X_PARENT_SEGMENT_ID,
  ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
  ATTRIBUTE1 = X_ATTRIBUTE1,
  ATTRIBUTE2 = X_ATTRIBUTE2,
  ATTRIBUTE3 = X_ATTRIBUTE3,
  ATTRIBUTE4 = X_ATTRIBUTE4,
  ATTRIBUTE5 = X_ATTRIBUTE5,
  ATTRIBUTE6  = X_ATTRIBUTE6,
  ATTRIBUTE7 = X_ATTRIBUTE7,
  ATTRIBUTE8 = X_ATTRIBUTE8,
  ATTRIBUTE9 = X_ATTRIBUTE9,
  ATTRIBUTE10 = X_ATTRIBUTE10,
  ATTRIBUTE11 = X_ATTRIBUTE11,
  ATTRIBUTE12 = X_ATTRIBUTE12,
  ATTRIBUTE13 = X_ATTRIBUTE13,
  ATTRIBUTE14 = X_ATTRIBUTE14,
  ATTRIBUTE15 = X_ATTRIBUTE15,
--  Should not be updating creation date, created by
--  CREATION_DATE =  X_CREATION_DATE,
--  CREATED_BY = X_CREATED_BY,
  LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
  REQUEST_ID = X_REQUEST_ID,
  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
  PROGRAM_ID = X_PROGRAM_ID,
  PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID;
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' After updating AR_LOCATION_VALUES_OLD ');
  END IF;

  if (sql%notfound) then
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('updating AR_LOCATION_VALUES_OLD: No Data Found !! ');
    END IF;
    raise no_data_found;
  end if;
*/
  if  X_LOCATION_VALUE_ACCOUNT_ID is not null then
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' Before updating AR_LOCATION_ACCOUNTS ');
    END IF;
    UPDATE AR_LOCATION_ACCOUNTS_ALL  set
    LOCATION_VALUE_ACCOUNT_ID = X_LOCATION_VALUE_ACCOUNT_ID,
    LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID,
    TAX_ACCOUNT_CCID = X_TAX_ACCOUNT_CCID,
    INTERIM_TAX_CCID = X_INTERIM_TAX_CCID,
    ADJ_CCID = X_ADJ_CCID,
    EDISC_CCID = X_EDISC_CCID,
    UNEDISC_CCID = X_UNEDISC_CCID,
    FINCHRG_CCID = X_FINCHRG_CCID,
    ADJ_NON_REC_TAX_CCID  =  X_ADJ_NON_REC_TAX_CCID,
    EDISC_NON_REC_TAX_CCID = X_EDISC_NON_REC_TAX_CCID,
    UNEDISC_NON_REC_TAX_CCID = X_UNEDISC_NON_REC_TAX_CCID,
    FINCHRG_NON_REC_TAX_CCID = X_FINCHRG_NON_REC_TAX_CCID,
--    Should not be updating creation date, created by
--    CREATION_DATE = X_CREATION_DATE,
--    CREATED_BY = X_CREATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
    WHERE  LOCATION_VALUE_ACCOUNT_ID  = X_LOCATION_VALUE_ACCOUNT_ID;

    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' After updating AR_LOCATION_ACCOUNTS ');
    END IF;
  end if;
 /*
  if (sql%notfound) then
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('updating AR_LOCATION_ACCOUNTS: No Data Found!! ');
    END IF;
    raise no_data_found;
  end if;
*/
  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.update_row(-) ');
  END IF;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOCATION_SEGMENT_ID in NUMBER,
  X_LOCATION_VALUE_ACCOUNT_ID in NUMBER
) is
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
begin

  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.delete_row(+) ');
  END IF;
  if  X_LOCATION_VALUE_ACCOUNT_ID is not null then
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' Before deleting AR_LOCATION_ACCOUNTS ');
    END IF;
    DELETE FROM  AR_LOCATION_ACCOUNTS_ALL
    WHERE LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID
    AND LOCATION_VALUE_ACCOUNT_ID = X_LOCATION_VALUE_ACCOUNT_ID;
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' After deleting AR_LOCATION_ACCOUNTS ');
    END IF;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  if  X_LOCATION_SEGMENT_ID is not null then
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' Before deleting AR_LOCATION_VALUES_OLD ');
    END IF;
    DELETE FROM  AR_LOCATION_VALUES_OLD
    WHERE LOCATION_SEGMENT_ID = X_LOCATION_SEGMENT_ID;
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug(' After deleting AR_LOCATION_VALUES_OLD ');
    END IF;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug(' AR_LOCVS_PKG.delete_row(-) ');
    END IF;
end DELETE_ROW;

end AR_LOCVS_PKG;

/
