--------------------------------------------------------
--  DDL for Package Body XXAH_INLEZEN_PRIJSLIJSTEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_INLEZEN_PRIJSLIJSTEN" is
-- $Id: XXAH_INLEZEN_PRIJSLIJSTEN.pkb 387 2011-12-12 11:22:30Z radu.lascae@oracle.com $
   ----------------------------------------
   -- l o c a l   d e c l a r a t i o n s :
   ----------------------------------------

   -- variables:
   g_organization_name CONSTANT hr_organization_units.name%TYPE := 'Ahold European Sourcing BV';
   g_article_sequence  fnd_document_sequences.db_sequence_name%type := NULL;
   g_item_set          mtl_system_items_interface.set_process_id%type := 999;

   l_actie_vk          XXAH_po_interface.actie%type                 default ' ';
   l_raamcontr_vk      XXAH_po_interface.raamcontr%type             default ' ';
   l_leverancier_vk    XXAH_po_interface.leverancier%type           default ' ';
   l_vestiging_vk      XXAH_po_interface.vestiging%type             default ' ';
   l_header_id         po_headers_interface.interface_header_id%type default 0;
   l_line_id           po_lines_interface.interface_line_id%type     default 0;
   l_attr_values_id      po_attr_values_interface.interface_attr_values_id%type default 0;
   l_attr_values_tlp_id  po_attr_values_tlp_interface.interface_attr_values_tlp_id%type default 0;
   l_template          po_lines_interface.template_name%type         default ' ';
   l_old_new           varchar2(3)                                   default ' ';
   l_org_id            po_headers_interface.org_id%type;
   l_line_num          po_lines_interface.line_num%type;
   l_staffel_allowed   boolean                                       default false;
   l_valid_staffelrec  boolean                                       default false;

   l_ingangsdatum_vk      XXAH_po_interface.ingangsdatum%type;
   l_einddatum_vk         XXAH_po_interface.einddatum%type;
   l_artikelnr_vk         XXAH_po_interface.artikelnr%type;
   l_artikeloms_vk        XXAH_po_interface.artikeloms%type;
   l_lev_artikelnr_vk     XXAH_po_interface.lev_artikelnr%type;
   l_int_artikeloms_vk    XXAH_po_interface.int_artikeloms%type;
   l_eenheid_vk           XXAH_po_interface.eenheid%type;
   l_prijs_vk             XXAH_po_interface.prijs%type;
   l_lange_artikeloms_vk  XXAH_po_interface.lange_artikeloms%type;

   l_inkoopcategorie_vk   XXAH_po_interface.inkoopcategorie%type;

   p_actie             XXAH_po_interface.actie%type;
   p_raamcontr         XXAH_po_interface.raamcontr%type;
   p_raamcontr_previous XXAH_po_interface.raamcontr%type := 0;
   p_leverancier       XXAH_po_interface.leverancier%type;
   p_vestiging         XXAH_po_interface.vestiging%type;
   p_ingangsdatum      XXAH_po_interface.ingangsdatum%type;
   p_einddatum         XXAH_po_interface.einddatum%type;
   p_artikelnr         XXAH_po_interface.artikelnr%type;
   p_artikeloms        XXAH_po_interface.artikeloms%type;
   p_lev_artikelnr     XXAH_po_interface.lev_artikelnr%type;
   p_int_artikeloms    XXAH_po_interface.int_artikeloms%type;
   p_eenheid           XXAH_po_interface.eenheid%type;
   p_prijs             XXAH_po_interface.prijs%type;
   p_lange_artikeloms  XXAH_po_interface.lange_artikeloms%type;

   p_inkoopcategorie   XXAH_po_interface.inkoopcategorie%type;
   p_staffelnr         XXAH_po_interface.staffelnr%type;
   p_hoeveelheid       XXAH_po_interface.hoeveelheid%type;
   p_staffelprijs      XXAH_po_interface.staffelprijs%type;
   p_staffelkorting    XXAH_po_interface.staffelkorting%type;
   p_geldig_vanaf      XXAH_po_interface.geldig_vanaf%type;
   p_geldig_tm         XXAH_po_interface.geldig_tm%type;
   p_vendor_id         po_vendors.vendor_id%type;
   p_vendor_site_id    po_vendor_sites_all.vendor_site_id%type;

   --p_buying_dep        XXAH_po_interface.buying_dep%type;
   p_controller        XXAH_po_interface.controller%type;
   p_status            XXAH_po_interface.status%type;
   p_buyer             po_headers_interface.agent_name%type;
   p_buyer_id          po_headers_interface.agent_id%type;
   p_sum_purchase_value     XXAH_po_interface.purchase_value%type;
   p_currency           xxah_po_interface.currency%TYPE;

  e_no_contracts_found exception;
  e_too_many_contracts_found exception;

  e_invoerfouten   exception;

  -- ----------------------------------------------------------------------
  -- Private constants
  -- ----------------------------------------------------------------------
  gc_package_name             CONSTANT VARCHAR2(  32)                            := 'xxah_inlezen_prijslijsten';
  gc_log_prefix               CONSTANT VARCHAR2(  50)                            := 'apps.plsql.'
                                                                                 || gc_package_name
                                                                                 || '.';

  gc_eenheid                  CONSTANT VARCHAR2( 30) := 'Base Unit';


  PROCEDURE log_contract_errors;

   -- write message to logfile:
   procedure msg
             ( p_text  in varchar2
             );

    -- write message to output file (and logfile as well)
    procedure msg_out
    ( p_text  in varchar2
    );

   -- write error to logfile:
   procedure fout
             ( p_text  in varchar2
             );

   -- valideren maatwerktabel:
   function  no_errors_in_input
             return boolean;

   -- vullen en schrijven van de open interface tabellen:
   FUNCTION aanmaak_openinterface_tabellen
   RETURN BOOLEAN;


   -- bepaal nieuw artikelnummer
   function bepaal_sequence return varchar2;


----------------------------------------------------------------------------------------
-- m a a t w e r k t a b e l   n a a r   o p e n   i n t e r f a c e   t a b e l l e n :
----------------------------------------------------------------------------------------
procedure maatwerk2openinterface
( errbuf                  in out varchar2   -- nodig voor Apps
, retcode                 in out varchar2   -- nodig voor Apps
)
is
   cursor   c_raamcontract
   is
   select   actie
   ,        raamcontr
   ,        leverancier
   ,        supplier_id    vendor_id
   ,        vestiging
   ,        ingangsdatum
   ,        einddatum
   ,        artikelnr
   ,        artikeloms
   ,        eenheid
   ,        prijs
   ,        lange_artikeloms
   ,        inkoopcategorie
   ,        staffelnr
   ,        hoeveelheid
   ,        staffelprijs
   ,        staffelkorting
   ,        geldig_vanaf
   ,        geldig_tm
   ,        header_id
   ,        line_id
   ,        old_new
   ,        buying_dep
   ,        controller
   ,        buyer
   ,        buyer_id
   ,        status
   ,        TO_OPEN_INTERFACE_STATUS
   ,        sum(purchase_value) over (partition by xpoh.raamcontr) sum_purchase_value
   ,        currency
   from     XXAH_po_interface xpoh
   where    actie = 'ORIGINAL'
            and
            (TO_OPEN_INTERFACE_STATUS is null
            or TO_OPEN_INTERFACE_STATUS = 'E')
   ORDER BY raamcontr
   for      update of header_id, line_id, old_new, TO_OPEN_INTERFACE_STATUS;

   r_raamcontract   c_raamcontract%rowtype;
   l_fouten_ontdekt boolean := false;
   e_invoerfouten   exception;
   e_programmafout  exception;
   v_staffelnr XXAH_po_interface.staffelnr%TYPE;
   v_artikelnr XXAH_po_interface.artikelnr%TYPE;

   l_contract_counter     NUMBER := 0;
   l_line_counter         NUMBER := 0;

   l_contracts_original   NUMBER := 0;
   l_contracts_update     NUMBER := 0;
   l_lines_original       NUMBER := 0;
   l_lines_update         NUMBER := 0;

   -- Count per currency the amount being processed
   TYPE t_pv_amount IS TABLE OF NUMBER INDEX BY VARCHAR2(3);  -- index is currency code
   l_pv_amount t_pv_amount;
   l_currency   VARCHAR2(3) := NULL;

   -- function toegevoegd voor MST / R12
   function get_org_id
   ( p_organization_name hr_organization_units.name%type )
   return hr_organization_units.organization_id%type
   is
     cursor c_get_org_id
     ( b_organization_name hr_organization_units.name%type
     ) is
       select hou.organization_id
       from   hr_organization_units hou
       where  hou.name = b_organization_name;

     lv_org_id  hr_organization_units.organization_id%type;
   begin
     open c_get_org_id(p_organization_name);
     fetch c_get_org_id into lv_org_id;
     if c_get_org_id%notfound
     then
       lv_org_id := null;
       msg('  Organisatie ' || p_organization_name|| ' niet gevonden.');
     end if;
     close c_get_org_id;

     return lv_org_id;
   end get_org_id;

begin
   msg_out('START Overbrengen raamcontract naar open interface tabellen.');

   -- first truncate the error logging table
   execute immediate 'truncate table xxah.xxah_contract_errors';

   -- ophalen profile:
   fnd_profile.get('XXAH_TEMPLATE_NAME', l_template);
   msg(' Template: '||l_template||'.');

   -- bepalen org_id:
   l_org_id := get_org_id(g_organization_name);
   if l_org_id is null then raise e_programmafout; end if;
   msg(' Organization_id: '||to_char(l_org_id)||'.');

   v_staffelnr := 0;
   l_line_num  := 1;


    -- Output ter info:
    msg_out('');
    msg_out('****************************************');
    msg_out('Count records in XXAH_PO_INTERFACE');
    msg_out('     - ORIGINAL: Will be transferred to Oracle Open Interface Tables');
    msg_out('     - UPDATE: Will be discarded');
    msg_out('');
    msg_out('');

    SELECT COUNT( DISTINCT raamcontr)
      INTO l_contracts_original
    FROM xxah_po_interface
    WHERE actie = 'ORIGINAL';

    SELECT COUNT( DISTINCT raamcontr)
      INTO l_contracts_update
    FROM xxah_po_interface
    WHERE actie = 'UPDATE';

    SELECT COUNT(*)
      INTO l_lines_original
    FROM xxah_po_interface
    WHERE actie = 'ORIGINAL';

    SELECT COUNT(*)
      INTO l_lines_update
    FROM xxah_po_interface
    WHERE actie = 'UPDATE';


    msg_out( RPAD('TYPE', 25, ' ')
      || ': ' || RPAD('TOTAL', 15, ' ')
      || RPAD('ORIGINAL (transfer)', 25, ' ')
      || RPAD('UPDATE (discard)', 25, ' ')
      );
    msg_out('-----------------------------------------------------------------------------');
    msg_out(RPAD('Contracts', 25, ' ')
      || ': ' || RPAD(to_number(l_contracts_original + l_contracts_update), 15, ' ')
      || RPAD(l_contracts_original, 25, ' ')
      || RPAD(l_contracts_update, 25, ' ')
     );

    msg_out(RPAD('Lines', 25, ' ')
      || ': ' || RPAD(to_number( l_lines_original + l_lines_update ), 15, ' ')
      || RPAD(l_lines_original, 25, ' ')
      || RPAD(l_lines_update, 25, ' ')
    );

    FOR rec IN (  SELECT SUM(xpo.purchase_value) pv_total
                  , xpo.currency
                  , ( SELECT SUM(xpo2.purchase_value)
                      FROM xxah_po_interface xpo2
                      WHERE xpo2.actie = 'ORIGINAL'
                      AND xpo2.currency = xpo.currency
                     ) pvorig
                  , ( SELECT SUM(xpo2.purchase_value)
                      FROM xxah_po_interface xpo2
                      WHERE xpo2.actie = 'UPDATE'
                      AND xpo2.currency = xpo.currency
                     ) pvupdate
                  FROM xxah_po_interface xpo
                  WHERE xpo.actie IS NOT NULL
                  GROUP BY xpo.currency
                  ORDER BY xpo.currency
             )
    LOOP
      msg_out(RPAD('Purchase Value (' || rec.currency || ')', 25, ' ')
        || ': ' || RPAD(rec.pv_total, 15, ' ')
        || RPAD(rec.pvorig, 25, ' ')
        || RPAD(rec.pvupdate, 25, ' ')
        );
    END LOOP;
    msg_out('');
    msg_out('ORIGINAL records will be transferred to the Oracle Open Interface tables');
    msg_out('UPDATE records will be discarded! Contracts are already present in Oracle E-Business Suite');
    msg_out('');
    msg_out('');

-- Note:
-- Het lijkt erop dat er voor elke record in XXAH_po_interface
-- een record wordt aangemaakt in po_headers_interface
-- ECHTER: in de aanmaak_openinterface_tabellen procedure
--         wordt er alleen maar een record aangemaakt als het een
--         'nieuw' / ander PO Nummer betreft.
--         ergo: Alle andere lines worden genegeerd
   -- verwerk raamcontract in maatwerktabel:
   for r_raamcontract in c_raamcontract
   loop
      -- cursor variabelen naar GLOBAAL gedefinieerde package variabelen
      -- daardoor zijn ze in alle procedures en functies te benaderen
      -- en hoef je geen parameters door te geven:
      -- altijd leuk voor geheugengebruik..
      p_actie             := r_raamcontract.actie;
      p_raamcontr         := r_raamcontract.raamcontr;
      p_leverancier       := r_raamcontract.leverancier;
      p_vendor_id         := r_raamcontract.vendor_id;
      p_vestiging         := r_raamcontract.vestiging;
      p_ingangsdatum      := r_raamcontract.ingangsdatum;
      p_einddatum         := r_raamcontract.einddatum;
      p_artikelnr         := r_raamcontract.artikelnr;
      p_artikeloms        := r_raamcontract.artikeloms;
      p_eenheid           := r_raamcontract.eenheid;
      p_prijs             := r_raamcontract.prijs;
      p_lange_artikeloms  := r_raamcontract.lange_artikeloms;
      p_status            := r_raamcontract.status;


      p_inkoopcategorie   := r_raamcontract.inkoopcategorie;

      --p_buying_dep         := r_raamcontract.buying_dep;
      p_controller         := r_raamcontract.controller;
      p_buyer              := r_raamcontract.buyer;
      p_buyer_id           := r_raamcontract.buyer_id;

      p_sum_purchase_value  := r_raamcontract.sum_purchase_value;
      p_currency            := r_raamcontract.currency;


      -- eerst controleren op fouten:
      -- geen fouten? dan overbrengen naar open interface tabellen, en id's opslaan in maatwerktabel:

      if no_errors_in_input
      then
         -- Alleen bij daadwerkelijk een nieuw contract aanmaken
         IF aanmaak_openinterface_tabellen
         THEN
            -- Ophogen contracten teller  -- original countract counter
            l_contract_counter := l_contract_counter + 1;

            -- *****************************
            -- Update PV count
            IF NOT l_pv_amount.EXISTS(p_currency)
            THEN
               l_pv_amount(p_currency) := 0;
            END IF;

            -- Update currency count
            l_pv_amount(p_currency) :=
                l_pv_amount(p_currency)
                + p_sum_purchase_value;
            --****************************
         END IF;

         l_line_counter := l_line_counter + 1;

         --
         update XXAH_po_interface
         set    header_id = l_header_id
         ,      line_id   = l_line_id
         ,      old_new   = l_old_new
         ,      artikelnr = p_artikelnr -- wanneer deze leeg was wordt bij controle in no_errors_in_input artikelnummer bepaald uit sequence
         ,      TO_OPEN_INTERFACE_STATUS = 'OK'
         where  current of c_raamcontract;
         msg('openinterface_header_id:'|| l_header_id ||
             ' openinterface_line_id:'|| l_line_id ||
             ' project:'|| p_artikeloms);

      else
         l_fouten_ontdekt := true;
      end if;


   end loop;


   if l_fouten_ontdekt
   then
     raise e_invoerfouten;
   end if;

   commit;


    msg_out('');
    msg_out( '**************************************' );
    msg_out( 'Transferred the following records to Open Interface:' );
    msg_out('');
    msg_out( RPAD('TYPE', 25, ' ')
      || ': ' || RPAD('TRANSFERRED', 15, ' ')
      );
    msg_out('-----------------------------------------------------------------------------');
    msg_out( RPAD('Contracts',25,' ')
      || ': ' || l_contract_counter );
    msg_out( RPAD('Lines',25,' ')
      || ': ' || l_line_counter );

    l_currency := l_pv_amount.FIRST;
    LOOP
      EXIT WHEN l_currency IS NULL;

      msg_out( RPAD('Purchase Value (' || l_currency || ')', 25, ' ')
          || ': ' || l_pv_amount(l_currency) );
      l_currency := l_pv_amount.NEXT(l_currency);
    END LOOP;
    msg_out( '' );

    msg(l_contract_counter || ' contracten overgezet naar de open interface tabellen');
    msg('');
    msg('Er zijn GEEN fouten geconstateerd.');
    msg('EINDE Overbrengen raamcontract naar open interface tabellen.');

exception
   when e_invoerfouten then
      -- geef foutmelding in de log:
      msg('In de invoer zijn fouten geconstateerd; de run wordt afgebroken.');
      msg('ABORT Overbrengen raamcontract naar open interface tabellen.');

      log_contract_errors;

      app_exception.raise_exception;
   when others then
      -- sluit evt. openstaande cursoren:
      if c_raamcontract%isopen
      then
         close c_raamcontract;
      end if;
      -- geef foutmelding in de log:
      msg('ERROR! De volgende fout is opgetreden: ' || sqlerrm );

      log_contract_errors;

      app_exception.raise_exception;
end maatwerk2openinterface;


----------------------------------------------------
-- w r i t e   m e s s a g e   t o   l o g f i l e :
----------------------------------------------------
procedure msg
( p_text  in varchar2
)
is
begin
   fnd_file.put_line
   ( fnd_file.LOG
   , p_text
   );
end msg;


----------------------------------------------------
-- w r i t e   m e s s a g e   t o   O u t f i l e :
----------------------------------------------------
procedure msg_out
( p_text  in varchar2
)
is
begin
  msg( p_text );     -- also write to log

   fnd_file.put_line
   ( fnd_file.OUTPUT
   , p_text
   );
end msg_out;


procedure contract_error
( p_contract in varchar2
  , p_text  in varchar2
)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
--   fnd_file.put_line
--   ( fnd_file.LOG
--   , 'Error: ' || p_text
--   );
   -- Try out: Als alle fouten hiermee gelogged worden:
   -- Use framework logging

   INSERT INTO xxah_contract_errors( contract, error, timestamp )
          VALUES (p_contract, p_text, SYSDATE );
   COMMIT;
end contract_error;



------------------------------------------------
-- w r i t e   e r r o r   t o   l o g f i l e :
------------------------------------------------
procedure fout
( p_contract in varchar2
, p_text  in varchar2
)
is
begin
-- achteraf loggen
/*
   fnd_file.put_line
   ( fnd_file.LOG
   , 'Error: ' || p_text
   );
*/

  contract_error( p_contract, p_text );
end fout;


------------------------------------------------
-- w r i t e   e r r o r   t o   l o g f i l e :
------------------------------------------------
procedure fout
( p_text  in varchar2
)
is
begin
   fnd_file.put_line
   ( fnd_file.LOG
   , 'Error: ' || p_text
   );


  contract_error( NULL, p_text );
end fout;









--------------------------------------------------
-- v a l i d e r e n   m a a t w e r k t a b e l :
--------------------------------------------------
function no_errors_in_input
   return boolean
is

   cursor   c_vendor
   (b_vendor_id po_vendors.vendor_id%type
   ,b_vendor_name po_vendors.vendor_name%type)
   is
   select   1
   from     po_vendors
   where    vendor_id = b_vendor_id
   and      vendor_name = b_vendor_name;    -- 16-DEC-2011: Added check again
                                            -- This should match!
   -- do return vendor_name for logging and correction

   cursor   c_vendor_site
   is
   --       bestaat leveranciers-vestiging?
   select   1
   from     po_vendor_sites
   where    vendor_id = p_vendor_id
   and      vendor_site_id = p_vestiging;

   cursor   c_eenheid
   is
   --       bestaat eenheid?
   select   1
   from     mtl_units_of_measure
   where    unit_of_measure = p_eenheid;

   cursor   c_inkoopcategorie
      (b_inkoopcategorie MTL_CATEGORY_SET_VALID_CATS_V.category_concat_segments%type)
   is
   --       bestaat inkoopcategorie?
   select   1
   from     MTL_CATEGORY_SET_VALID_CATS_V      a
   where    a.category_concat_segments = b_inkoopcategorie
   and      CATEGORY_SET_name='PO Item Category';


    -- bestaat controller_id ?
    cursor   c_controller
      (b_controller_id      FND_FLEX_VALUES.flex_value%type)
    is
      select
        1
      from
        per_all_people_f ppf, per_person_types ppt, per_business_groups bg, per_all_assignments_f  paa, per_jobs pjo
      WHERE
        ppt.person_type_id      = ppf.person_type_id +0
        AND     ppt.system_person_type in ('EMP','EMP_APL','APL','APL_EX_APL','EX_EMP_APL')
        and ppf.business_group_id = bg.business_group_id
        and  ppf.effective_start_date =
          (select max(effective_start_date)
          from    per_all_people_f    ppf1
          where   ppf1.person_id  = ppf.person_id)
        and ppf.person_id = paa.person_id
        and sysdate between paa.effective_start_date and paa.effective_end_date
        and paa.job_id = pjo.job_id
        and pjo.name = 'Controller'
        and ppf.person_id = b_controller_id;

    -- bestaat c_bueyr_id ?
    cursor   c_buyer
      ( b_buyer_id      fnd_user.employee_id%type
      , b_buyer_name    fnd_user.user_name%type)
    is
      SELECT
        1
      FROM
        PO_AGENTS PoAgentEO
        , PER_ALL_PEOPLE_F PAPF
        , PO_SHIP_TO_LOC_ORG_V PSL
        , MTL_CATEGORIES_KFV MKFV
        , fnd_user fu
      WHERE
        PoAgentEO.AGENT_ID = PAPF.PERSON_ID
        AND PoAgentEO.CATEGORY_ID = MKFV.CATEGORY_ID(+)
        AND (PAPF.EMPLOYEE_NUMBER IS NOT NULL OR PAPF.NPW_NUMBER IS NOT NULL)
        AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
        AND DECODE(HR_GENERAL.GET_XBG_PROFILE,'Y', PAPF.BUSINESS_GROUP_ID, HR_GENERAL.GET_BUSINESS_GROUP_ID) = PAPF.BUSINESS_GROUP_ID
        AND PoAgentEO.LOCATION_ID = PSL.LOCATION_ID(+)
        AND FU.employee_id = PAPF.person_id
        AND fu.employee_id = b_buyer_id
        AND fu.user_name = b_buyer_name;


   l_dummy    pls_integer;
   l_foutloos boolean;

   l_cat_delimiter  fnd_id_flex_structures.concatenated_segment_delimiter%type;
   l_cat_segments   number;

   l_hospital fnd_profile_option_values.profile_option_value%type := NVL(fnd_profile.value('XXAH_HOSPITAL'),'UNKNOWN');
begin
/*
Uit te voeren controles:
p_actie             Verplicht
p_raamcontr          Verplicht.
p_leverancier        Verplicht. + checken
p_vendor_id          Verplicht. + checken
p_vestiging          Verplicht. + checken
p_ingangsdatum       --
p_einddatum          --
p_artikelnr          --
p_artikeloms         Verplicht.
p_eenheid            Verplicht. Altijd Base Unit.
p_prijs              --
p_lange_artikeloms   Verplicht.
p_korting1           --
p_korting2           --
p_einddatum2         --
p_afbeelding         --
p_inkoopcategorie    Verplicht. Checken!

-- CRD
p_buying_dep         Verplicht. Checken!
p_controller         Verplicht. Checken!
p_buyer              Verplicht. Checken!
p_buyer_id           Verplicht. Checken!

*/
   l_foutloos := true;
--return true;

   if p_actie is null
   then
      l_foutloos := false;
      msg(' Actie is niet ingevuld. Moet zijn: ORIGINAL of UPDATE.');

   else
      if p_actie not in ('ORIGINAL','UPDATE')
      then
         l_foutloos := false;
         fout( p_raamcontr, ' Actie '||p_actie||' is ongeldig. Moet zijn: ORIGINAL of UPDATE.');

      end if;
   end if;

   if p_raamcontr is null
      and p_actie in ('UPDATE','REPLACE')
      then
         l_foutloos := false;
         fout( p_raamcontr, ' Raamcontractnummer is niet ingevuld.');
   end if;


   if p_leverancier is null
   then
      l_foutloos := false;
      fout( p_raamcontr, ' Leveranciersnaam is niet ingevuld. Is verplicht.');

   else

      open c_vendor (p_vendor_id, p_leverancier );
      fetch c_vendor into l_dummy;
      if c_vendor%notfound
      then
         l_foutloos := false;
         close c_vendor;
         fout( p_raamcontr, ' Leverancier id /name '||p_vendor_id|| ' / '  || p_leverancier || ' niet gevonden ' );   -- rvelden 16-dec-2011
      else
         close c_vendor;
      end if;
    end if;


    if p_lange_artikeloms is null
    then
        l_foutloos := false;
        fout( p_raamcontr, 'Lange artikelomschrijving is niet ingevuld. Is verplicht.');
    end if;

    if p_artikeloms is null
    then
      l_foutloos := false;
      fout( p_raamcontr, 'Artikelomschrijving is niet ingevuld. Is verplicht.');
    end if;


    if p_eenheid is not null
      then
         open c_eenheid;
         fetch c_eenheid into l_dummy;
         if c_eenheid%notfound
         then
            l_foutloos := false;
            fout( p_raamcontr, ' Eenheid '||p_eenheid||' bestaat niet.');
         end if;
         close c_eenheid;

          if p_eenheid <> gc_eenheid -- 'Base Unit'
              then
                l_foutloos := false;
                fout( p_raamcontr, 'Eenheid moet altijd ''' || gc_eenheid || ''' zijn.');
          end if;
      end if;

    if p_inkoopcategorie is not null
    then
      open c_inkoopcategorie(p_inkoopcategorie);
      fetch c_inkoopcategorie into l_dummy;
        if c_inkoopcategorie%notfound  then
          l_foutloos := false;
          fout( p_raamcontr, ' Inkoopcategorie '||p_inkoopcategorie||' bestaat niet.');
        end if;
      close c_inkoopcategorie;
    end if;

    if p_vestiging is not null
    then
      open c_vendor_site;
      fetch c_vendor_site into l_dummy;
        if c_vendor_site%notfound  then
          l_foutloos := false;
          fout( p_raamcontr, ' Vestiging met id  '||p_vestiging||' bestaat niet.');
        end if;
      close c_vendor_site;
    end if;

     if p_ingangsdatum is null or p_einddatum is null
     then
       l_foutloos := false;
       fout( p_raamcontr, 'Zowel ingangsdatum als einddatum verplicht.');
     end if;

     if p_einddatum < p_ingangsdatum then
       l_foutloos := false;
       fout( p_raamcontr, ' Einddatum mag niet liggen voor de begindatum van het contract.');
     end if;


    open c_controller (p_controller);
      fetch c_controller into l_dummy;
      if c_controller%notfound
      then
        l_foutloos := false;
        fout( p_raamcontr, ' Controller met id '||p_controller||' bestaat niet.');
      end if;
    close c_controller;

    open c_buyer (p_buyer_id, p_buyer);
      fetch c_buyer into l_dummy;
      if c_buyer%notfound
      then
        l_foutloos := false;
        fout( p_raamcontr, ' Buyer id '||p_buyer_id||' matched niet met buyer naam '|| p_buyer || '. Of buyer bestaat in het geheel niet.');
      end if;
    close c_buyer;

   if not l_foutloos
   then

      -- druk een blanko regel af om onderscheid te maken tussen de verschillende records:
      fout(' ');
   end if;

   return l_foutloos;

exception
   when others then
      -- sluit evt. openstaande cursoren:
      if c_vendor%isopen then
        close c_vendor;
      end if;

      if c_inkoopcategorie%isopen then
        close c_inkoopcategorie;
      end if;

      if c_eenheid%isopen then
        close c_eenheid;
      end if;

     /* if c_buying_department%isopen then
        close c_buying_department;
      end if;*/

      if c_controller%isopen then
        close c_controller;
      end if;

      if c_buyer%isopen then
        close c_buyer;
      end if;

      if c_vendor_site%isopen then
        close c_vendor_site;
      end if;
      -- geef foutmelding in de log:
      msg('ERROR! De volgende fout is opgetreden tijdens de validatie: ' || sqlerrm );
      app_exception.raise_exception;
end no_errors_in_input;


------------------------------------------------------------------
-- a a n m a a k   o p e n   i n t e r f a c e   t a b e l l e n :
------------------------------------------------------------------
FUNCTION aanmaak_openinterface_tabellen
RETURN BOOLEAN
is
   cursor   c_header_seq
   is
   select   po_headers_interface_s.nextval
   from     dual;

   cursor   c_line_seq
   is
   select   po_lines_interface_s.nextval
   from     dual;

   cursor   c_attr_values_seq
   is
   select   po_attr_values_interface_s.nextval
   from     dual;

   cursor   c_attr_values_tlp_seq
   is
   select   po_attr_values_tlp_interface_s.nextval
   from     dual;

   l_plaats               varchar2(50) default '--';
   l_value_blanket        varchar2(7)  default 'BLANKET';
   l_value_pending        varchar2(7)  default 'PENDING';



begin

   if p_raamcontr              <> p_raamcontr_previous

   then
      -- dit is een ander raamcontract dan de vorige keer => nieuwe header aanmaken
      p_raamcontr_previous := p_raamcontr;
      l_plaats := 'Ophalen header sequence';
      open c_header_seq;
      fetch c_header_seq into l_header_id;
      close c_header_seq;


      l_plaats := 'Insert into po_headers_interface';
      insert into po_headers_interface
      ( interface_header_id
      , process_code
      , action
      , document_type_code
      --, document_num
      , org_id -- toegevoegd voor MST/R12
      , vendor_name
      , vendor_id
      , vendor_site_id
      , effective_date
      , expiration_date

      ,created_by
      ,creation_date
      ,currency_code
      ,last_updated_by

     , agent_name ---buyer_name
     , agent_id  ---buyer_id

     , approval_status
     , comments
     , amount_agreed
     , attribute_category
     , attribute11
      )
      values
      ( l_header_id
      , l_value_pending
      , p_actie
      , l_value_blanket
      --, p_raamcontr
      , l_org_id -- toegevoegd voor MST/R12
      , p_leverancier
      , p_vendor_id
      , p_vestiging
--      , p_vendor_site_id

      , p_ingangsdatum
      , p_einddatum
--      ,61
      ,fnd_global.user_id -- 1090
      ,sysdate
      , p_currency        -- 'EUR'
      ,fnd_global.user_id -- 1090
      , p_buyer
      , p_buyer_id

       , p_status  -- status
       , p_artikeloms --comments
       , p_sum_purchase_value --amount_agreed
       , 'BLANKET'  --attribute_category
       , p_controller   --Controller
       );

      l_actie_vk        := p_actie;
      l_raamcontr_vk    := nvl(p_raamcontr,' ');
      l_leverancier_vk  := p_leverancier;
      l_vestiging_vk    := p_vestiging;


      -- JV: one line for each contract
     l_plaats := 'Ophalen line sequence';
     open c_line_seq;
     fetch c_line_seq into l_line_id;
     close c_line_seq;

     l_plaats := 'Insert into po_lines_interface';
    -- if p_staffelnr is null
   --  then
       insert into po_lines_interface
       ( interface_line_id
       , interface_header_id
       , line_num
       , action
       , item_description
       , vendor_product_num
       , unit_of_measure
       , line_attribute_category_lines
       , category
       ) values
       ( l_line_id
       , l_header_id
       , l_line_num
       , decode(p_actie, 'UPDATE', 'UPDATE', null)
       , p_artikeloms
       , p_lev_artikelnr
       , p_eenheid
       , l_value_blanket
       , p_inkoopcategorie
       );
       msg('Project inserted into po_headers_interface: ' || p_artikeloms );

      RETURN TRUE;
     end if;

    RETURN FALSE;
exception
   when others then
      -- sluit evt. openstaande cursoren:
      if c_header_seq%isopen
      then
         close c_header_seq;
      end if;
      if c_line_seq%isopen
      then
         close c_line_seq;
      end if;
      if c_attr_values_seq%isopen
      then
         close c_attr_values_seq;
      end if;
      -- geef foutmelding in de log:
      msg('ERROR! De volgende fout is opgetreden tijdens het vullen van de open interface tabellen: ' || sqlerrm );
      msg('Laatste actie was in: '||l_plaats);
      app_exception.raise_exception;
end aanmaak_openinterface_tabellen;



-- aanmaken short_text attachments (voor PO_LINE)
PROCEDURE create_po_line_sh_txt_att(
      p_pk1_value       VARCHAR2        -- PO_LINE_ID
    , p_short_text      VARCHAR2        -- SHORT_TEXT ATTACHMENT (max VARCHAR(4000))
)
IS
  l_attached_document_id number;
  l_document_id number := NULL;
  l_rowid rowid;
  l_media_id number;
  l_seq_num number;
  l_category_id number;

BEGIN
  msg( 'create_po_line_sh_txt_att - start' );

  SELECT FND_ATTACHED_DOCUMENTS_S.nextval
  into l_attached_document_id
  from dual;

  SELECT fnd_documents_short_text_s.nextval
  INTO l_media_id
  FROM DUAL;

  SELECT nvl(max(seq_num),0) + 1
  INTO l_seq_num
  FROM fnd_attached_documents
  WHERE pk1_value = p_pk1_value
  AND entity_name = 'PO_LINES';

  SELECT category_id
  INTO l_category_id
  FROM  fnd_document_categories
  WHERE name = 'Vendor';

  -- Create short text message in short_text message table
  -- Media_id was generated using sequence, will be used as reference later
  INSERT INTO fnd_documents_short_text( media_id, short_text, app_source_version )
  VALUES ( l_media_id, p_short_text, NULL );

  -- Create attachment for PO_LINE with po_line_id p_pk1_value
  -- Create fnd_document as well l_document_id IS NULL and X_create_doc = Y
    -- Use l_media_id (just created shorttext) as the media
  fnd_attached_documents_pkg.insert_row
  ( X_ROWID => l_rowid
  , X_ATTACHED_DOCUMENT_ID => l_attached_document_id
  , X_DOCUMENT_ID => l_document_id
  , X_CREATION_DATE => sysdate
  , X_CREATED_BY => fnd_profile.value('USER_ID')
  , X_LAST_UPDATE_DATE => sysdate
  , X_LAST_UPDATED_BY => fnd_profile.value('USER_ID')
  , X_LAST_UPDATE_LOGIN => fnd_profile.value('LOGIN_ID')
  , X_SEQ_NUM => l_seq_num
  , X_ENTITY_NAME => 'PO_LINES'
  , X_COLUMN1 => null
  , X_PK1_VALUE => p_pk1_value
  , X_PK2_VALUE => null
  , X_PK3_VALUE => null
  , X_PK4_VALUE => null
  , X_PK5_VALUE => null
  , X_AUTOMATICALLY_ADDED_FLAG => 'N'
  , X_DATATYPE_ID => 1
  , X_CATEGORY_ID => l_category_id
  , X_SECURITY_TYPE => 1
  , X_PUBLISH_FLAG => 'Y'
  , X_LANGUAGE => 'NL'
  , X_MEDIA_ID => l_media_id
  , X_create_doc => 'Y'
  );

  COMMIT;
  msg( 'create_po_line_sh_txt_att - end' );

EXCEPTION
WHEN OTHERS THEN
  msg( 'Error occurred in create_po_line_sh_txt_att: ' || DBMS_UTILITY.format_error_backtrace );
  RAISE;
END create_po_line_sh_txt_att;

------------------------------------------------------------------------------------------------------------
-- e x t r a   v e r w e r k i n g s s t a p p e n   n a   i m p o r t e r e n   p r i j s c a t a l o g i :
------------------------------------------------------------------------------------------------------------
procedure after_import
( errbuf                  in out varchar2   -- nodig voor Apps
, retcode                 in out varchar2   -- nodig voor Apps
)
is

  cursor c_open_interface_errors
    (b_request_id  mtl_interface_errors.request_id%type
    ) is
    select mie.message_name,
           mie.column_name,
           mie.error_message,
           mii.attribute30
    from   mtl_interface_errors mie
    ,      mtl_system_items_interface mii
    where  mie.request_id = b_request_id
    and    mii.transaction_id = mie.transaction_id
    and    mii.transaction_id <> 0;


   CURSOR c_attachments
   IS
     SELECT pli.po_line_id
       , xpi.bijlage_tekst
       , xpi.actie
     FROM XXAH_po_interface xpi
     , po_lines_interface pli
     WHERE xpi.line_id = pli.interface_line_id
     --AND xpi.actie = 'REPLACE'
     AND xpi.line_id IS NOT NULL
     AND xpi.bijlage_tekst IS NOT NULL	-- RVELDEN: 8 feb 2010: no attachments -> no action
   ;

   l_plaats          varchar2(50)                                             default '--';

   l_count_new_items       number;
   l_organization_id_MST   mtl_parameters.organization_id%type;
   l_request_id            number;
   l_message               varchar2(2000);
   l_result                boolean;
   l_phase                 varchar2(20);
   l_status                varchar2(20);
   l_dev_phase             varchar2(20);
   l_dev_status            varchar2(20);
   l_completion_message    varchar2(20);
   l_message_tx            mtl_interface_errors.error_message%type;

   e_programmafout  exception;

  function get_organization_id
  ( p_organization_code mtl_parameters.organization_code%type )
  return mtl_parameters.organization_id%type
  is
    cursor c_get_organization_id
      ( b_organization_code mtl_parameters.organization_code%type
      ) is
      select organization_id
      from   mtl_parameters
      where  organization_code = b_organization_code;

    l_organization_id  mtl_parameters.organization_id%type;

  begin
    open c_get_organization_id(p_organization_code);
    fetch c_get_organization_id into l_organization_id;

    if c_get_organization_id%notfound
    then
      l_organization_id := null;
      msg('  Voorraadorganisatie ' || nvl(p_organization_code,'NULL') || ' niet gevonden.');
    end if;

    close c_get_organization_id;
    return l_organization_id;
  end get_organization_id;

begin
  msg('"xxah_inlezen_prijslijsten.after_import" should not be used.');
  app_exception.raise_exception;
   msg('START Extra verwerkingsstappen na importeren prijscatalogi.');
   msg(' ');
   msg('Bijwerken leveranciers artikelnummer, kortingspercentage''s en/of afbeelding');
   msg(' ');

   l_plaats := 'create_po_line_sh_txt_att';
   for r_attachments in c_attachments
   loop
     IF r_attachments.actie IN ( 'REPLACE', 'ORIGINAL' ) THEN
      -- creeer bijlage op nieuwe po
      create_po_line_sh_txt_att(
            p_pk1_value         => r_attachments.po_line_id
          , p_short_text        => r_attachments.bijlage_tekst
        );
     ELSIF r_attachments.actie = 'UPDATE' THEN
     -- update attachement text
       UPDATE fnd_documents_short_text
       SET short_text = r_attachments.bijlage_tekst
       WHERE media_id =
          ( SELECT fd.media_id
            FROM fnd_attached_documents fad
              LEFT JOIN fnd_documents fd
              ON ( fd.document_id=fad.document_id )
            WHERE fad.pk1_value = r_attachments.po_line_id
            AND fad.entity_name = 'PO_LINES'
            AND rownum = 1
          )
        ;

     END IF;
   end loop;



exception
   when others then
      -- sluit evt. openstaande cursoren:
      if c_open_interface_errors%isopen
      then
         close c_open_interface_errors;
      end if;


      -- geef foutmelding in de log:
      msg('ERROR! De volgende fout is opgetreden: ' || sqlerrm );
      msg('Laatste actie was in: '||l_plaats);
      app_exception.raise_exception;
end after_import;

------------------------------------------------------
-- b e p a a l  n i e u w  a r t i k e l n u m m e r :
------------------------------------------------------
function bepaal_sequence
return varchar2
is
  cursor c_seq_name
  is
    select dsc.db_sequence_name
    from   fnd_document_sequences dsc
    where  dsc.name = 'Artikelnummering'
    ;
  l_statement     VARCHAR2(2000);
BEGIN
  if g_article_sequence is null
  then
    open  c_seq_name;
    fetch c_seq_name
    into  g_article_sequence;
    close c_seq_name;
  end if;

  if g_article_sequence is null
  then
    -- Article sequence can not be determined !!!
    return '';
  end if;

  l_statement := 'begin select '||g_article_sequence||'.nextval into XXAH_inlezen_prijslijsten.g_art_seq_number from dual; end;';

  execute immediate l_statement;

  return to_char(g_art_seq_number);

exception
  when others then
    if c_seq_name%isopen then close c_seq_name; end if;
    return '';
end bepaal_sequence;

  ------------------------------------------------------
  -- this procedure is called after uploading attachments
  ------------------------------------------------------
  PROCEDURE process_uploaded_file(X_file_id IN NUMBER DEFAULT NULL) IS
  BEGIN
    NULL;
  END;

  ------------------------------------------------------
  -- this procedure is called after uploading attachments
  ------------------------------------------------------
  procedure process_uploaded_files
    ( errbuf                  in out varchar2   -- nodig voor Apps
    , retcode                 in out varchar2   -- nodig voor Apps
    )
    IS

    l_doc_category_id NUMBER;
    l_document_id NUMBER;
    l_attached_document_id NUMBER;
    p_pk1_value NUMBER;
    l_media_id NUMBER;
    l_seq_num NUMBER;
    l_fnd_user_id NUMBER;
    l_fnd_login_id NUMBER;
    l_doc_datatype_id NUMBER;
    l_description VARCHAR2(1024) := 'CRD Conversion';
    l_filename VARCHAR2(1024);
    l_contract VARCHAR2(1024);
    l_number_of_contracts NUMBER;
    l_rowid VARCHAR2(1024);
    l_new_contract BOOLEAN;

    CURSOR c_attachments
  IS
    SELECT
      file_name l_filename
      , program_tag l_contract
      , file_id  l_file_id
    FROM   fnd_lobs fl
    WHERE  program_name = 'XXAH_CRD_CONVERSION'
    FOR UPDATE OF EXPIRATION_DATE
    ;

  BEGIN

    msg('Start process_uploaded_files');

    FOR r_attachments in c_attachments LOOP

      l_new_contract := true;

      -- check how many ebs-contracts are new with this project_number (new means that the comments field start with the lotus number)
      select
        count(*) into l_number_of_contracts
      from
        po_headers_all poh
      where
        substr(poh.comments,0, instr(poh.comments, '|')-1) = r_attachments.l_contract;

      if l_number_of_contracts < 1 then
        -- the contract couold not be found.
        -- was it already available in EBS?

        select
          -- blanket_ebs
          count(*) into l_number_of_contracts
        from
          xxah_contract_conv_data
        where
          cocon = 'N'
          and exists_in_ebs = 'Y'
          and project_number = r_attachments.l_contract;

        -- is it a new contract
        if l_number_of_contracts = 1 then
          l_new_contract := false;
        end if;

      end if;

      l_media_id := r_attachments.l_file_id;

      msg('');
      msg('r_attachments.l_contract : '|| r_attachments.l_contract);
      msg('Number of contracts found: '|| l_number_of_contracts);
      msg('l_media_id               : '|| l_media_id);

      -- if still no contracts found, then set the attachment to expired.
      if l_number_of_contracts < 1 then
        -- set expire date
        UPDATE
          fnd_lobs
        SET
          EXPIRATION_DATE = sysdate
        WHERE current of c_attachments;
      -- if too many contracts found, raise exception
      elsif l_number_of_contracts > 1 then
        raise e_too_many_contracts_found;
      else

        -- new contract?
        if l_new_contract then

          select
            po_header_id into p_pk1_value
          from
            po_headers_all poh where substr(poh.comments,0, instr(poh.comments, '|')-1) = r_attachments.l_contract;

        else -- existing contract
          select
            max(po_header_id) into p_pk1_value
          from
            xxah_contract_conv_data xxah
            , po_headers_all poh
          where
            cocon = 'N'
            and exists_in_ebs = 'Y'
            and project_number = r_attachments.l_contract
            and poh.segment1 = substr( xxah.blanket_ebs,instr(xxah.blanket_ebs, '___')+3
            , instr(xxah.blanket_ebs, '___', 1,2)
              - ( instr(xxah.blanket_ebs, '___') + 3 )
            );
          end if;

        msg('p_pk1_value              : '|| p_pk1_value);

        -- Get Data type id for File types of attachments
        SELECT datatype_id
        INTO l_doc_datatype_id
        FROM apps.fnd_document_datatypes
        WHERE name ='FILE';

        -- Select nexvalues of document id, attached document id
        SELECT
          apps.fnd_documents_s.NEXTVAL
          , apps.fnd_attached_documents_s.NEXTVAL
        INTO
          l_document_id
          , l_attached_document_id
        FROM DUAL;

        SELECT nvl(max(seq_num),0) + 1
        INTO l_seq_num
        FROM fnd_attached_documents
        WHERE pk1_value = p_pk1_value
        AND entity_name = 'PO_HEADERS';

        -- Select Category id for "MISC" Attachments
        SELECT category_id
        INTO l_doc_category_id
        FROM apps.fnd_document_categories
        WHERE name = 'MISC';


          -- Select User_id
        SELECT fnd_profile.value('USER_ID')
        INTO l_fnd_user_id
        FROM dual;
        -- apps.fnd_user
        -- WHERE user_name ='WWIT';
        msg('user_id                  : '|| l_fnd_user_id);

        SELECT fnd_profile.value('LOGIN_ID')
        INTO l_fnd_login_id
        FROM dual;
        -- apps.fnd_user
        -- WHERE user_name ='WWIT';
        msg('l_fnd_login_id           : '|| l_fnd_login_id);

        msg('fnd_documents_pkg.insert_row');
        fnd_documents_pkg.insert_row
        ( X_ROWID => l_rowid
        , X_DOCUMENT_ID => l_document_id
        , X_CREATION_DATE => sysdate
        , X_CREATED_BY => l_fnd_user_id
        , X_LAST_UPDATE_DATE => sysdate
        , X_LAST_UPDATED_BY => l_fnd_user_id
        , X_LAST_UPDATE_LOGIN => l_fnd_login_id
        , X_DATATYPE_ID => l_doc_datatype_id
        , X_CATEGORY_ID => l_doc_category_id
        , X_SECURITY_TYPE => 1
        , X_PUBLISH_FLAG => 'Y'
        , X_USAGE_TYPE => 'O'
        , X_LANGUAGE => 'US'
        , X_DESCRIPTION => l_description
        , X_FILE_NAME => r_attachments.l_filename
        , X_MEDIA_ID => l_media_id
        );

        msg('fnd_documents_pkg.insert_tl_row');
        fnd_documents_pkg.insert_tl_row
        ( X_DOCUMENT_ID => l_document_id
        , X_CREATION_DATE => sysdate
        , X_CREATED_BY => l_fnd_user_id
        , X_LAST_UPDATE_DATE => sysdate
        , X_LAST_UPDATED_BY => l_fnd_user_id
        , X_LAST_UPDATE_LOGIN => l_fnd_login_id
        , X_LANGUAGE => 'US'
        , X_DESCRIPTION => l_description
        --, X_FILE_NAME => l_filename
        --, X_MEDIA_ID => l_media_id
        , X_title => r_attachments.l_filename
        );


        -- Create attachment for PO_LINE with po_line_id p_pk1_value
        -- Create fnd_document as well l_document_id IS NULL and X_create_doc = Y
          -- Use l_media_id (just created shorttext) as the media
        msg('fnd_attached_documents_pkg.insert_row');
        fnd_attached_documents_pkg.insert_row
        ( X_ROWID => l_rowid
        , X_ATTACHED_DOCUMENT_ID => l_attached_document_id
        , X_DOCUMENT_ID => l_document_id
        , X_CREATION_DATE => sysdate
        , X_CREATED_BY => l_fnd_user_id
        , X_LAST_UPDATE_DATE => sysdate
        , X_LAST_UPDATED_BY => l_fnd_user_id
        , X_LAST_UPDATE_LOGIN => l_fnd_login_id
        , X_SEQ_NUM => l_seq_num
        , X_ENTITY_NAME => 'PO_HEADERS'
        , X_COLUMN1 => null
        , X_PK1_VALUE => p_pk1_value
        , X_PK2_VALUE => null
        , X_PK3_VALUE => null
        , X_PK4_VALUE => null
        , X_PK5_VALUE => null
        , X_AUTOMATICALLY_ADDED_FLAG => 'N'
        , X_DATATYPE_ID => 1
        , X_CATEGORY_ID => l_doc_category_id
        , X_SECURITY_TYPE => 1
        , X_PUBLISH_FLAG => 'Y'
        , X_LANGUAGE => 'US'
        , X_MEDIA_ID => l_media_id
        , X_create_doc => 'Y'
        );
      END IF;
    END LOOP;


    EXCEPTION WHEN OTHERS THEN
    --handle exception
    msg ('Error. Updating not OK! Rollback');
    msg(SQLCODE || ' ' || SUBSTR(SQLERRM, 1, 100));

  END process_uploaded_files;



FUNCTION check_supplier( p_contract VARCHAR2
          , p_supplier_id VARCHAR2
          , p_supplier_name VARCHAR2 )
RETURN BOOLEAN
IS
  CURSOR c_vendor(b_supplier_id VARCHAR2)
  IS
    SELECT vendor_name
    from po_vendors
    where vendor_id = to_number(b_supplier_id);

  l_dummy po_vendors.vendor_name%TYPE;
BEGIN
     OPEN c_vendor( p_supplier_id );
     FETCH c_vendor INTO l_dummy;
     IF c_vendor%NOTFOUND THEN
        CLOSE c_vendor;
        -- log and raise
        fout( p_contract, '001; Supplier not found for id: ' || p_supplier_id );
        RETURN FALSE;
        --RAISE e_invoerfouten;
     END IF;
     CLOSE c_vendor;

     IF p_supplier_name != l_dummy
     THEN
      -- log and raise
      fout( p_contract, '001b; Supplier name incorrect for id: ' || p_supplier_id || ' name in database ' || l_dummy || ' did not correspond with entered value ' || p_supplier_name );
      RETURN FALSE;
     END IF;

     RETURN TRUE;
EXCEPTION WHEN INVALID_NUMBER THEN
  fout( p_contract, '001; Supplier not found for id: ' || p_supplier_id || ' / ' || SQLERRM );
  RETURN FALSE;
  --RAISE e_invoerfouten;
END check_supplier;



FUNCTION check_buyer( p_contract VARCHAR2
 , p_buyer_id VARCHAR2
 , p_buyer_name VARCHAR2 )
RETURN BOOLEAN
IS
  CURSOR c_buyer_id( b_buyer_id VARCHAR2 )
  IS
  SELECT 1
  FROM po_buyers_all_v
  WHERE employee_id = to_number(b_buyer_id)
  ;

  CURSOR c_buyer_name( b_buyer_id VARCHAR2
         , b_buyer_name VARCHAR2 )
  IS
  SELECT 1
  FROM fnd_user
  WHERE employee_id = to_number(b_buyer_id)
  AND user_name = b_buyer_name
  ;

  l_dummy PLS_INTEGER;
BEGIN
  OPEN c_buyer_id( p_buyer_id );
  FETCH c_buyer_id INTO l_dummy;
  IF c_buyer_id%NOTFOUND THEN
     CLOSE c_buyer_id;
     -- log and raise
     fout( p_contract, '003; Buyer not found for id: ' || p_buyer_id || ' / ' || SQLERRM );
     RETURN FALSE;
     --RAISE e_invoerfouten;
  END IF;
  CLOSE c_buyer_id;


  OPEN c_buyer_name( p_buyer_id, p_buyer_name );
  FETCH c_buyer_name INTO l_dummy;
  IF c_buyer_name%NOTFOUND THEN
     CLOSE c_buyer_name;
     -- log and raise
     fout( p_contract, '004; Buyer name not found or incorrect for id/name: ' || p_buyer_id || ' / ' || p_buyer_name || '  /  ' || SQLERRM );
     RETURN FALSE;
     --RAISE e_invoerfouten;
  END IF;
  CLOSE c_buyer_name;

  RETURN TRUE;
EXCEPTION WHEN INVALID_NUMBER THEN
  -- log error and reraise exception
  fout( p_contract, '003; Buyer not found for id: ' || p_buyer_id || ' / ' || SQLERRM );
  RETURN FALSE;
  --RAISE e_invoerfouten;
END check_buyer;



FUNCTION check_category( p_contract VARCHAR2
 , p_category VARCHAR2 )
RETURN BOOLEAN
IS
  CURSOR c_category( b_category VARCHAR2 )
  IS
    SELECT 1
    FROM MTL_CATEGORY_SET_VALID_CATS_V
    WHERE CATEGORY_SET_name='PO Item Category'
    AND category_concat_segments = b_category
  ;

  l_dummy PLS_INTEGER;
BEGIN
     OPEN c_category( p_category );
     FETCH c_category INTO l_dummy;
     IF c_category%NOTFOUND THEN
        CLOSE c_category;
        -- log and raise
        fout( p_contract, '005; Category not found: ' || p_category  );
        RETURN FALSE;
        --RAISE e_invoerfouten;
     END IF;
     CLOSE c_category;

     RETURN TRUE;
END check_category;



FUNCTION check_purchase_value( p_contract VARCHAR2
  , p_purchase_value NUMBER
  , p_currency VARCHAR2
  , p_proc_purchase_value NUMBER
  , p_proc_currency VARCHAR2
 )
RETURN BOOLEAN
IS
BEGIN
  IF p_currency != p_proc_currency
  THEN
    fout( p_contract, '006; Currency mismatch between xxah_contract_conv_data and xxah_po_interface: ' || p_currency || ' does not match with ' || p_proc_currency  );
    RETURN FALSE;
  ELSIF p_purchase_value != p_proc_purchase_value
  THEN
    fout( p_contract, '007; Purchase Value mismatch between xxah_contract_conv_data and xxah_po_interface: ' || p_purchase_value || ' does not match with ' || p_proc_purchase_value  );
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END check_purchase_value;


FUNCTION check_controller( p_contract VARCHAR2
 , p_controller VARCHAR2 )
RETURN BOOLEAN
IS
  CURSOR c_controller( b_controller VARCHAR2 )
  IS
    SELECT 1
    FROM per_all_people_f ppf
         , per_person_types ppt
         , per_business_groups bg
         , per_all_assignments_f  paa
         , per_jobs pjo
    WHERE ppt.person_type_id      = ppf.person_type_id +0
    AND     ppt.system_person_type in ('EMP','EMP_APL','APL','APL_EX_APL','EX_EMP_APL')
    AND ppf.business_group_id = bg.business_group_id
    AND  ppf.effective_start_date =
          (select max(effective_start_date)
          from    per_all_people_f    ppf1
          where   ppf1.person_id  = ppf.person_id)
    AND ppf.person_id = paa.person_id
    AND sysdate between paa.effective_start_date and paa.effective_end_date
    AND paa.job_id = pjo.job_id
    AND pjo.name = 'Controller'
    AND ppf.person_id = to_number( b_controller )
  ;

  l_dummy PLS_INTEGER;
BEGIN
     OPEN c_controller( p_controller );
     FETCH c_controller INTO l_dummy;
     IF c_controller%NOTFOUND THEN
        CLOSE c_controller;
        -- log and raise
        fout( p_contract, '008; Controller not found: ' || p_controller  );
        RETURN FALSE;
        --RAISE e_invoerfouten;
     END IF;
     CLOSE c_controller;

     RETURN TRUE;
EXCEPTION WHEN INVALID_NUMBER THEN
  -- log error and reraise exception
  fout( p_contract, '009; Controller not found for id: ' || p_controller || ' / ' || SQLERRM );
  RETURN FALSE;
  --RAISE e_invoerfouten;
END check_controller;



-- Logging contract errors afterwards
--   - Copy paste this part of the log to Excel
--     for futher analysis / fixing of input file
--
PROCEDURE log_contract_errors
IS
BEGIN
  msg( '' );
  msg( '************************************************************' );
  msg( ' 2) Logging grouped by contract, error' );
  msg( 'distinct contract, errors:' );
  msg( '' );

  --select distinct contract, error from xxah_contract_errors
  msg( 'CONTRACT; ERROR' );
  FOR rec IN (SELECT DISTINCT contract
                     , error
               FROM xxah_contract_errors
               ORDER BY contract )
  LOOP
      msg( rec.contract || ';' || rec.error );
  END LOOP;

  msg( '' );
  msg( '' );
  msg( '************************************************************' );
  msg( ' 3) Logging grouped by error:' );
  msg( '' );

  --select distinct error from xxah_contract_errors
  msg( 'ERROR' );
  FOR rec IN (SELECT DISTINCT error
               FROM xxah_contract_errors )
  LOOP
      msg( rec.error );
  END LOOP;

END;





----------------------------------------------------------------------------------------
-- enrich procurement contracts (based on contracts data) :
----------------------------------------------------------------------------------------
procedure CRD_enrich_proc_contracts
( errbuf                  in out varchar2   -- nodig voor Apps
, retcode                 in out varchar2   -- nodig voor Apps
)
is
    cursor   c_projects_to_update
    is
    select   proc.raamcontr      project
    ,        proc.artikeloms          description
    ,        project.category category
    ,        replace(REGEXP_SUBSTR(project.supplier,'.*\|\|\|'),'|||', '') supplier
    ,        replace(REGEXP_SUBSTR(project.supplier,'\|\|\|.*'),'|||', '') supplier_id
    ,        replace(REGEXP_SUBSTR(project.controller,'\|\|\|.*'),'|||', '') controller
    ,        replace(REGEXP_SUBSTR(project.contract_admin,'.*\|\|\|'),'|||', '') buyer
    ,        replace(REGEXP_SUBSTR(project.contract_admin,'\|\|\|.*'),'|||', '') buyer_id
    --,        buying_department    buying_dep
    ,        project.cocon
    ,        project.exists_in_ebs
    ,        project.blanket_ebs blanket_ebs_orig    -- 25-01-2012 Rvelden: This value should be put in blanket_ebs!
    , SUBSTR(REGEXP_SUBSTR(project.blanket_ebs, '___[0-9]*'),4) blanket_ebs -- 14-10-2011 Rvelden: extract blanket number from project.blanket_ebs
    ,        REPLACE(REPLACE(REPLACE(project.status, CHR(10)), CHR(13)), CHR(9)) status
    ,        (select vendor_site_id from po_vendor_sites_all where to_char(vendor_id) =
              replace(REGEXP_SUBSTR(project.supplier,'\|\|\|.*'),'|||', '')  -- vendor_id
              and purchasing_site_flag = 'Y'                -- purchasing site
              and NVL(inactive_date, SYSDATE+1) > SYSDATE   -- active site
              and rownum = 1)  vendor_site_id
-- compare purchase value and currency between proc/project
    , project.purchase_value  purchase_value
    , project.currency        currency
    , SUM(proc.purchase_value) OVER (PARTITION BY proc.raamcontr) proc_purchase_value
    , proc.currency           proc_currency
    , proc.purchase_value     proc_line_purchase_value
-- additional checks on proc table (copied from maatwerk2openinterface
    , proc.lange_artikeloms
    , proc.artikeloms
    , proc.eenheid
    , proc.ingangsdatum
    , proc.einddatum
    , proc.actie
    FROM     XXAH_po_interface proc
    ,        xxah_contract_conv_data project
    WHERE    project.cocon = 'N'
             and project.project_number = proc.raamcontr
    FOR UPDATE OF
             proc.actie
             , proc.inkoopcategorie
             , proc.leverancier
             , proc.supplier_id
             , proc.controller
             , proc.buyer
             , proc.buyer_id
             , proc.exists_in_ebs
             , proc.blanket_ebs
             , proc.vestiging
             , proc.status
             nowait;

   cursor   c_existing_project
      (b_project_number      po_headers_all.segment1%type)
    is
      select 1 from
        po_headers_all
      where
        b_project_number = po_headers_all.segment1;


   -- Total PV in xxah_contract_conv_data
   CURSOR c_pv_contract_conv_data
   IS
     SELECT SUM( purchase_value ) pv
          , currency              currency
     FROM xxah_contract_conv_data
     GROUP BY currency
     ORDER BY currency
   ;


   -- Total PV in xxah_po_interface
   CURSOR c_pv_po_interface
   IS
     SELECT SUM(purchase_value) pv
            , currency          currency
     FROM xxah_po_interface
     WHERE raamcontr IN (SELECT project_number
                        FROM xxah_contract_conv_data
                        )
     GROUP BY currency
     ORDER BY currency
   ;


   r_projects_to_update   c_projects_to_update%rowtype;

   l_proc_headers_count   number := 0;
   l_proc_lines_count   number := 0;

   l_proc_project_count  number := 0;
   l_core_project_count  number := 0;
   l_total_project_count  number := 0;
   l_proc_matching_headers number := 0;
   l_proc_matching_lines number := 0;

   -- Actual count of updated records
   l_enriched_lines_count number := 0;       -- actual count of enriched XXAH_PO_INTERFACE records
   l_enriched_contracts_count number := 0;   -- actual count of enriched contracts
   l_previous_contract_number VARCHAR2(200) := NULL;

   -- Actual count of Purchase Value amount being enriched
   TYPE t_pv_amount IS TABLE OF NUMBER INDEX BY VARCHAR2(3);  -- index is currency code
   l_pv_amount t_pv_amount;
   l_currency VARCHAR2(3);


   l_error_record BOOLEAN := FALSE;          -- Per record status of error conditions

   resource_busy exception;
   pragma exception_init(resource_busy,-54);
   l_dummy    pls_integer;

   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(2000);
   l_msg_index_out         NUMBER;
   l_formatted_msg         VARCHAR2(2000);
   l_error_message         VARCHAR2(2000);
   lc_subprogram_name      CONSTANT VARCHAR2(30) := 'CRD_enrich_proc_contracts';

begin
   msg_out('START Enrichment of procurement contracts');

   -- first truncate the error logging table
   execute immediate 'truncate table xxah.xxah_contract_errors';

   -- Begin tellingen:
   --   - Totaal te verwerken: XXAH_CONTRACT_CONV_DATA
   --            - Onderverdeling in Cocon en Procurement
   --   - Totaal aantal te verrijken records XXAH_PO_INTERFACE en XXAH_PO_INTERFACE_VA

   -- Procurement contract count
   SELECT COUNT(DISTINCT project_number)
          INTO l_proc_project_count
   FROM xxah_contract_conv_data
   WHERE cocon = 'N';

   -- Core Contract count
   SELECT COUNT(DISTINCT project_number)
          into l_core_project_count
   FROM xxah_contract_conv_data
   WHERE cocon = 'Y';

   -- Total project count
   SELECT COUNT(DISTINCT project_number)
          INTO l_total_project_count
   FROM xxah_contract_conv_data;



   msg_out('Conversion Data: (xxah_contract_conv_data)');
   msg_out('# Procurement projects (xxah_contract_conv_data) :'  || l_proc_project_count);
   msg_out('# Cocon projects       (xxah_contract_conv_data) :'  || l_core_project_count);
   msg_out('# Total projects       (xxah_contract_conv_data) :'  || l_total_project_count);
   msg_out( '' );

   -- Total enrichment contract count
   SELECT COUNT (DISTINCT raamcontr)
          into l_proc_headers_count
   FROM XXAH_po_interface;

   -- Total enrichment line count
   SELECT COUNT (raamcontr)
          INTO l_proc_lines_count
   FROM XXAH_po_interface;

   -- Total enrichment line count (for this conversion run)
   SELECT COUNT(raamcontr)
      INTO l_proc_matching_lines
   FROM xxah_po_interface
   WHERE raamcontr IN (SELECT project_number
                      FROM xxah_contract_conv_data);

   -- Total enrichment contract count (for this conversion run)
   SELECT COUNT( DISTINCT raamcontr)
       INTO l_proc_matching_headers
   FROM xxah_po_interface
   WHERE raamcontr IN (SELECT project_number
                      FROM xxah_contract_conv_data
                      );


   msg_out('Enrichment data (xxah_po_interface)');
   msg_out('# Total distinct projects (XXAH_po_interface)                        : '  || l_proc_headers_count);
   msg_out('# Total distinct projects matching xxah_contract_conv_data           : ' || l_proc_matching_headers );
   msg_out('# Total enrichment lines (XXAH_po_interface)                         : ' || l_proc_lines_count);
   msg_out('# Total enrichment lines matching projects in xxah_contract_conv_data: ' || l_proc_matching_lines );


   msg_out('');
   msg_out('');
   msg_out( 'Total Purchase Value amounts (currency)' );
   msg_out('');
   msg_out( '-- Total PV in xxah_contract_conv_data' );
   FOR r_pv_contract_conv_data IN c_pv_contract_conv_data
   LOOP
      msg_out( RPAD( r_pv_contract_conv_data.pv, 20, ' ') || ' ' || r_pv_contract_conv_data.currency );
   END LOOP;

   msg_out('');
   msg_out( '-- Total PV in xxah_po_interface' );
   FOR r_pv_po_interface IN c_pv_po_interface
   LOOP
      msg_out( RPAD( r_pv_po_interface.pv, 20, ' ' ) || ' ' || r_pv_po_interface.currency );
   END LOOP;

   msg_out( '' );
   msg_out( '' );

   -- Start processing / checking records
   msg('');
   msg('Log file structure:');
   msg(' 1) Sucessfully processed records are listed ');
   msg(' 2) Errors are listed grouped by contract, error ');
   msg(' 3) Errors are listed grouped by error ');
   msg('');
   msg('');
   msg(' 1) Sucessfully processed records');
   msg('The following projects are updated. If a project has multiple lines, this project is printed multiple times.');
   msg('project     |     description');


   -- Loop through all records
   FOR r_projects_to_update IN c_projects_to_update
   LOOP
   BEGIN
    l_error_record := FALSE;   -- Maintain error status using variable!
    -- Do not raise exception in between checks.
    -- Set l_error_record = TRUE instead

     -- check Blanket EBS
    if r_projects_to_update.exists_in_ebs = 'Y' then
      if r_projects_to_update.blanket_ebs is null then
        fout(r_projects_to_update.project, '018; if exists_in_ebs flag = ''Y'', then a EBS blanket_number should be provided.');
        l_error_record := TRUE;
      else
        open c_existing_project (r_projects_to_update.blanket_ebs);
          fetch c_existing_project into l_dummy;
          if c_existing_project%notfound then
             fout(r_projects_to_update.project, '019; Blanket '||r_projects_to_update.blanket_ebs||' does not exist in EBS.');
             l_error_record := TRUE;
          end if;
        close c_existing_project;
      end if; -- blanket_ebs is null
    end if; --  exists_in_ebs = 'Y'


    -- Check supplier
    IF check_supplier( r_projects_to_update.project
    , r_projects_to_update.supplier_id
    , r_projects_to_update.supplier )
        = FALSE
    THEN
        l_error_record := TRUE;
    END IF;

    -- Check buyer id and name
    IF check_buyer( r_projects_to_update.project, r_projects_to_update.buyer_id, r_projects_to_update.buyer )
       = FALSE
    THEN
        l_error_record := TRUE;
    END IF;

    -- Check category
    IF check_category( r_projects_to_update.project, r_projects_to_update.category )
       = FALSE
    THEN
        l_error_record := TRUE;
    END IF;

    -- Check controller
    IF check_controller( r_projects_to_update.project, r_projects_to_update.controller )
       = FALSE
    THEN
        l_error_record := TRUE;
    END IF;

    -- Check Purchase Value + currency (per contract)
    IF check_purchase_value( r_projects_to_update.project
      , r_projects_to_update.purchase_value
      , r_projects_to_update.currency
      , r_projects_to_update.proc_purchase_value
      , r_projects_to_update.proc_currency
     )
      = FALSE
    THEN
        l_error_record := TRUE;
    END IF;

    -- Check supplier site
    if r_projects_to_update.vendor_site_id is null then
       fout(r_projects_to_update.project, '002; No Site exists for supplier: '||r_projects_to_update.supplier);
       l_error_record := TRUE;
    end if;

    -- Check status
    if r_projects_to_update.status is null then
       fout(r_projects_to_update.project, '010; No status exists for project: '||r_projects_to_update.project);
       l_error_record := TRUE;
    elsif r_projects_to_update.status not in ('INCOMPLETE', 'APPROVED') then
       fout(r_projects_to_update.project, '011; Project: '||r_projects_to_update.project || '. Only status INCOMPLETE and APPROVED are allowed. Status '||r_projects_to_update.status|| ' is not allowed.');
       l_error_record := TRUE;
    end if;


    -- Controles op XXAH_PO_INTERFACE
    -- => kopie van controles op maatwerk2openinterface + no_errors_in_input

    -- p_lange_artikeloms
    IF r_projects_to_update.lange_artikeloms IS NULL
      OR r_projects_to_update.lange_artikeloms = ''
    THEN
      fout(r_projects_to_update.project, '012; lange_artikeloms is leeg!');
      l_error_record := TRUE;
    END IF;

     -- p_artikeloms
    IF r_projects_to_update.artikeloms IS NULL
      OR r_projects_to_update.artikeloms = ''
    THEN
      fout(r_projects_to_update.project, '013; artikeloms is leeg!');
      l_error_record := TRUE;
    END IF;

    -- p_eenheid 'Base Unit'
    IF r_projects_to_update.eenheid != gc_eenheid -- 'Base Unit'
    THEN
      fout(r_projects_to_update.project, '014; Eenheid niet gelijk aan ' || gc_eenheid );
      l_error_record := TRUE;
    END IF;

    -- p_ingangsdatum
    IF r_projects_to_update.ingangsdatum IS NULL
      OR r_projects_to_update.ingangsdatum = ''
    THEN
      fout(r_projects_to_update.project, '015; ingangsdatum is leeg!' );
      l_error_record := TRUE;
    END IF;

    -- p_einddatum
    IF r_projects_to_update.einddatum IS NULL
      OR r_projects_to_update.einddatum = ''
    THEN
      fout(r_projects_to_update.project, '016; einddatum is leeg!' );
      l_error_record := TRUE;
    END IF;

    IF  r_projects_to_update.einddatum < r_projects_to_update.ingangsdatum
    THEN
      fout(r_projects_to_update.project, '017; einddatum valt voor ingangsdatum (einddatum, ingangsdatum): ('
        || r_projects_to_update.einddatum
        || ', '
        || r_projects_to_update.ingangsdatum
        || ')' );
      l_error_record := TRUE;
    END IF;

    -- To support multiple failing checks:
    -- One record can fail on many different checks
    -- For input file fixing: We need to record ALL failing elements
    IF l_error_record = TRUE THEN
      RAISE e_invoerfouten;
    END IF;


    -- No l_error_record => implies => All checks passed
    -- Now we can update the XXAH_PO_INTERFACE
    UPDATE XXAH_po_interface proc
    SET
    actie               = DECODE(r_projects_to_update.exists_in_ebs, 'Y', 'UPDATE', 'N', 'ORIGINAL', 'invalid')
      , inkoopcategorie = r_projects_to_update.category
      , leverancier     = r_projects_to_update.supplier
      , supplier_id     = r_projects_to_update.supplier_id
      , controller      = r_projects_to_update.controller
      , buyer           = r_projects_to_update.buyer
      , buyer_id        = r_projects_to_update.buyer_id
      , exists_in_ebs   = r_projects_to_update.exists_in_ebs
      , blanket_ebs     = r_projects_to_update.blanket_ebs_orig -- 25-01-2012: Rvelden: Need to keep the XXX_BLANKET_YYY_ZZZ format in this column
      --, BUYING_DEP      = r_projects_to_update.buying_dep
      , vestiging       = r_projects_to_update.vendor_site_id
      , status          = r_projects_to_update.status
     where
       current of c_projects_to_update;

      -- keep count of enriched lines
      l_enriched_lines_count := l_enriched_lines_count + SQL%ROWCOUNT;

      -- Check whether a new contract has been enriched
      IF l_previous_contract_number IS NULL
        OR l_previous_contract_number != r_projects_to_update.project
      THEN
        -- keep count, and set this project as the last contract enriched.
        l_enriched_contracts_count := l_enriched_contracts_count+1;
        l_previous_contract_number := r_projects_to_update.project;
      END IF;

      --***************
      -- keep count of enriched purchase value per currency

      -- Initialize associative array for this currency code
      -- whenever it does not yet exist
      IF NOT l_pv_amount.EXISTS(r_projects_to_update.currency)
      THEN
        l_pv_amount(r_projects_to_update.currency) := 0;
      END IF;

      -- Update currency count
      l_pv_amount(r_projects_to_update.currency) :=
            l_pv_amount(r_projects_to_update.currency)
            + r_projects_to_update.proc_line_purchase_value;
      --****************************

      -- First: only log successfully processed contracts (errors printed later on)
      msg( r_projects_to_update.project
     || '     |     '
     || r_projects_to_update.description);

  EXCEPTION WHEN e_invoerfouten THEN
    -- In ieder geval 1 fout ontdekt; dus retcode is minimaal WARNING
    -- Fouten achteraf printen in concurrent output
    -- Tussentijds worden fouten gelogged in tijdelijke tabel
    -- Dit gebeurt via de FOUT routine
    retcode := 1;
  END;    -- end process errors per project
  END LOOP;


  msg_out( '' );
  msg_out( '***********************************************' );
  msg_out( 'Results of enrichment              : ' || RPAD('CONTRACTS',15,' ') || 'LINES' );
  msg_out( '' );
  msg_out( 'Total to be enriched (A)           : ' || RPAD(l_proc_matching_headers,15,' ')    || l_proc_matching_lines  );
  msg_out( 'Total sucessfully enriched (B)     : ' || RPAD(l_enriched_contracts_count,15,' ') || l_enriched_lines_count );
  msg_out( 'Total in error (A-B)               : ' || RPAD(to_number( l_proc_matching_headers - l_enriched_contracts_count ),15,' ') || to_number(l_proc_matching_lines - l_enriched_lines_count) );
  msg_out( '' );
  msg_out( '' );

  msg_out( 'Purchase Value processed:' );
  msg_out( RPAD('Amount',20,' ') || ' Currency' );
  msg_out( '--------------------------------' );
  l_currency := l_pv_amount.FIRST;
  LOOP
    EXIT WHEN l_currency IS NULL;
    msg_out( RPAD(l_pv_amount(l_currency), 20, ' ') || ' ' || l_currency );
    l_currency := l_pv_amount.NEXT(l_currency);
  END LOOP;
  msg_out( '' );
  msg_out( '' );
  msg_out( 'Please see logfile for errors' );

  -- Output naar log: Alle contract errors (gegroepeerd)
  log_contract_errors;



  EXCEPTION WHEN resource_busy THEN
    msg('ERROR: Table XXAH_po_interface can not be updated. The table is already in use.');
    retcode := 1; -- Warning
    l_error_message := '';
    l_msg_count := fnd_msg_pub.Count_Msg;

    IF l_msg_count > 0
    THEN
      FOR l_msg_index IN 1 .. l_msg_count
      LOOP
        fnd_msg_pub.Get
        ( p_msg_index     => l_msg_index
        , p_encoded       => 'F'
        , p_data          => l_msg_data
        , p_msg_index_out => l_msg_index_out
        );

        fnd_log.string
        ( fnd_log.level_exception
        , gc_log_prefix || lc_subprogram_name
        , l_msg_data
        );

        l_formatted_msg := '[' || l_msg_index || '] ' || l_msg_data || ' ';

        msg(l_formatted_msg);

        l_error_message := substr(l_error_message || l_formatted_msg || ' ', 0, 2000);

      END LOOP;
    ELSE
      NULL;
    END IF;
END CRD_enrich_proc_contracts;




  ----------------------------------------------------------------------------------------
  -- add saving types :
  ----------------------------------------------------------------------------------------
  PROCEDURE CRD_add_saving_types
  ( errbuf                  in out varchar2   -- nodig voor Apps
  , retcode                 in out varchar2   -- nodig voor Apps
  )
  IS

    -- new ebs contracts
    CURSOR   c_new_blankets
    IS
    SELECT
      po_header_id,
      (select min(po_line_id) from po_lines_all pol where poh.po_header_id = pol.po_header_id) po_line_id
      , raamcontr raam_contr
      , 'new blanket' new_existing
    FROM
      po_headers_all poh
      , xxah_po_interface xxpoi
    WHERE
      substr(poh.comments,0, instr(poh.comments, '|')-1) = xxpoi.raamcontr
      and xxpoi.actie = 'ORIGINAL'
      and NVL(xxpoi.CONVERSION_STATUS_SAVING_T, 'X') <> 'OK'
    order by
      raam_contr
    FOR UPDATE OF
      xxpoi.CONVERSION_STATUS_SAVING_T nowait;

    -- existing ebs contracts
    CURSOR c_existing_blankets
    IS
    SELECT
    poh.po_header_id
    , (select min(po_line_id) from po_lines_all pol where poh.po_header_id = pol.po_header_id) po_line_id
    , xxpoi.raamcontr raam_contr
    , 'existing blanket' new_existing
    FROM
      po_headers_all poh
      , xxah_po_interface xxpoi
    WHERE
      poh.segment1 =
      substr( xxpoi.blanket_ebs,instr(xxpoi.blanket_ebs, '___')+3
            , instr(xxpoi.blanket_ebs, '___', 1,2)
              - ( instr(xxpoi.blanket_ebs, '___') + 3 )
            )
      and NVL(xxpoi.CONVERSION_STATUS_SAVING_T, 'X') <> 'OK'
    ORDER BY poh.po_header_id
    FOR UPDATE OF xxpoi.CONVERSION_STATUS_SAVING_T nowait;

    l_output_string       varchar2(1000);

    l_prev_raamcontr      po_headers_all.attribute15%type;

    resource_busy exception;
    pragma exception_init(resource_busy,-54);

  BEGIN
    msg('START Adding saving types.');

    msg('');
    msg('The following NEW blankets are updated.');


    FOR v_new_blankets in c_new_blankets LOOP

      -- check if not already processed.
      IF NVL(l_prev_raamcontr, 'x') <> v_new_blankets.raam_contr THEN
        l_prev_raamcontr := v_new_blankets.raam_contr ;

        BEGIN
          SAVEPOINT update_new_blanket;

        UPDATE
          XXAH_po_interface proc
        SET
          CONVERSION_STATUS_SAVING_T  = 'P' -- Processing
        where
          proc.raamcontr = v_new_blankets.raam_contr;

        l_output_string := v_new_blankets.raam_contr|| '   | ';

       --TODO: build check for

       -- opco
       -- incentive_type
       -- year
       -- benefit

        INSERT INTO xxah_po_blanket_info
          ( po_header_id
          , po_line_id
          , description
          , savings_type
          , opco
          , year
          , estimated_savings
          , created_by
          , last_updated_by
          , last_update_login
          , creation_date
          , last_update_date
          )
        select
          v_new_blankets.po_header_id
          , v_new_blankets.po_line_id
          , null description
          , 'Purchase Value' savings_type
          , opco
          , year
          , purchase_value estimated_savings
          , fnd_global.user_id
          , null
          , null
          , sysdate
          , null
        from
          xxah_po_interface
        where
          raamcontr = v_new_blankets.raam_contr;


        l_output_string := l_output_string || sql%rowcount || ' PV''s added  |';

        INSERT INTO xxah_po_blanket_info
          ( po_header_id
          , po_line_id
          , description
          , savings_type
          , opco
          , year
          , estimated_savings
          , created_by
          , last_updated_by
          , last_update_login
          , creation_date
          , last_update_date)
        select
          v_new_blankets.po_header_id
          , v_new_blankets.po_line_id
          , null description
          , substr(incentive_type, 0, 25) savings_type
          , opco
          , year
          , benefit estimated_savings
          , fnd_global.user_id
          , null
          , null
          , sysdate
          , null
          from
		    xxah_po_interface_va
          where
		    raamcontr = v_new_blankets.raam_contr;

        l_output_string := l_output_string || sql%rowcount || ' benefits added  |';

        UPDATE
          XXAH_po_interface proc
        SET
          CONVERSION_STATUS_SAVING_T  = 'OK'
        where
          proc.raamcontr = v_new_blankets.raam_contr;
        msg(l_output_string);
        msg('Updating ready ***.');

        EXCEPTION WHEN OTHERS THEN
          --handle exception
          msg ('Error. Updating not OK! Rollback');
          msg( v_new_blankets.raam_contr || ';sqlcode / error' || SQLCODE || ' ' || SUBSTR(SQLERRM, 1, 100));
          ROLLBACK to update_new_blanket;

        UPDATE
          XXAH_po_interface proc
        SET
          CONVERSION_STATUS_SAVING_T  = 'Error'
        where
          proc.raamcontr = v_new_blankets.raam_contr;

        END;
      END IF;
    END LOOP;



    msg('');
    msg('The following EXISTING blankets are updated.');

    FOR v_existing_blankets in c_existing_blankets LOOP

      -- check if not already processed.
      IF NVL(l_prev_raamcontr, 'x') <> v_existing_blankets.raam_contr THEN
        l_prev_raamcontr := v_existing_blankets.raam_contr ;

        BEGIN
          SAVEPOINT update_existing_blanket;

        UPDATE
          XXAH_po_interface proc
        SET
          CONVERSION_STATUS_SAVING_T  = 'P' -- Processing
        where
          proc.raamcontr = v_existing_blankets.raam_contr;

        l_output_string := v_existing_blankets.raam_contr|| '   | ';

       --TODO: build check for

       -- opco
       -- incentive_type
       -- year
       -- benefit

        INSERT INTO xxah_po_blanket_info
          ( po_header_id
          , po_line_id
          , description
          , savings_type
          , opco
          , year
          , estimated_savings
          , created_by
          , last_updated_by
          , last_update_login
          , creation_date
          , last_update_date
          )
        select
          v_existing_blankets.po_header_id
          , v_existing_blankets.po_line_id
          , null description
          , 'Purchase Value' savings_type
          , opco
          , year
          , purchase_value estimated_savings
          , fnd_global.user_id
          , null
          , null
          , sysdate
          , null
        from
          xxah_po_interface
        where
          raamcontr = v_existing_blankets.raam_contr;

        l_output_string := l_output_string || sql%rowcount || ' PV''s added  |';

        INSERT INTO xxah_po_blanket_info
          ( po_header_id
          , po_line_id
          , description
          , savings_type
          , opco
          , year
          , estimated_savings
          , created_by
          , last_updated_by
          , last_update_login
          , creation_date
          , last_update_date)
        select
          v_existing_blankets.po_header_id
          , v_existing_blankets.po_line_id
          , null description
          , substr(incentive_type, 0, 25) savings_type
          , opco
          , year
          , benefit estimated_savings
          , fnd_global.user_id
          , null
          , null
          , sysdate
          , null
          from xxah_po_interface_va
          where raamcontr = v_existing_blankets.raam_contr;

        l_output_string := l_output_string || sql%rowcount || ' benefits added  |';

        UPDATE
          XXAH_po_interface proc
        SET
          CONVERSION_STATUS_SAVING_T  = 'OK'
        where
          proc.raamcontr = v_existing_blankets.raam_contr;
        msg(l_output_string);
        msg('Updating ready ***.');

        EXCEPTION WHEN OTHERS THEN
          --handle exception
          msg ('Error. Updating not OK! Rollback ' || v_existing_blankets.raam_contr );
          msg(SQLCODE || ' ' || SUBSTR(SQLERRM, 1, 100));
          ROLLBACK to update_existing_blanket;

        UPDATE
          XXAH_po_interface proc
        SET
          CONVERSION_STATUS_SAVING_T  = 'Error'
        where
          proc.raamcontr = v_existing_blankets.raam_contr;

        END;
      END IF;
    END LOOP;


END CRD_add_saving_types;



/* add function for checking

PV:
opco moet geldig zijn
year moet gevuld zijn

VA:
raamcontr moet bestaan
opco moet geldig zijn
incentive_type moet geldig zijn
year moet gevuld zijn

*/



end XXAH_inlezen_prijslijsten;

/
