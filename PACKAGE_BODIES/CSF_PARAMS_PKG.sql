--------------------------------------------------------
--  DDL for Package Body CSF_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_PARAMS_PKG" AS
/* $Header: CSFCPARB.pls 115.15.11510.2 2004/06/24 04:41:01 srengana ship $ */

  FUNCTION query_parameter
  ( i_name          varchar2
  , i_default_value number
  ) return number
  IS
    /******************************************************
     Created by: T. Voerman, Oracle Nederland

     Date created:

     Purpose: get numeric parametervalue.

     Known Limitations:

     Remarks:
    ********************************************************/

    r_read_parameter c_read_parameter%rowtype;
    t_return_value   number(34);

  BEGIN
    open c_read_parameter(i_name);
    fetch c_read_parameter into r_read_parameter;
    if c_read_parameter%found
    then
      t_return_value := To_Number(r_read_parameter.value);
    else
      t_return_value := i_default_value;
    end if;
    close c_read_parameter;
    return t_return_value;
  END query_parameter;

  FUNCTION query_parameter
  ( i_name          varchar2
  , i_default_value varchar2
  ) return varchar2
  IS
    /******************************************************
     Created by: T. Voerman, Oracle Nederland

     Date created:

     Purpose: get character parametervalue.

     Known Limitations:

     Remarks:
    ********************************************************/

    r_read_parameter c_read_parameter%rowtype;
    t_return_value   varchar2(2000);

  BEGIN
    open c_read_parameter(i_name);
    fetch c_read_parameter into r_read_parameter;
    if c_read_parameter%found
    then
      t_return_value := r_read_parameter.value;
    else
      t_return_value := i_default_value;
    end if;
    close c_read_parameter;
    return t_return_value;
  END query_parameter;

  PROCEDURE query_parameters ( io_param in out nocopy paramtab )
  IS
    /******************************************************
     Created by: T. Voerman, Oracle Nederland

     Date created:

     Purpose: get all parametervalues and store them in PL/SQL table.

     Known Limitations:

     Remarks:
    ********************************************************/

    cursor c_uom ( b_code varchar2 )
    is
      select uom_class
      ,      unit_of_measure
      ,      uom_code
      ,      base_uom_flag
      ,      unit_of_measure_tl
      ,      language
      from   mtl_units_of_measure_vl
      where  Upper(uom_class) = 'LENGTH'
      and    uom_code = b_code;

    -- The distinct-clause is important! The mtl_system_items
    -- table has a PK of the inventory_item_id and the organization_id
    -- combined. As the design decision has been to ignore the latter
    -- any particular inventory_item_id can exist more than once in the table.
    -- Show all the existing inventory_item_id's.
    cursor c_agenda_on_duty_item_id ( b_inventory_item_id number )
    is
      select distinct inventory_item_id
      ,      concatenated_segments
      from   mtl_system_items_vl
      where  inventory_item_id = b_inventory_item_id;

    cursor c_agenda_trip_blg_type_id ( b_txn_billing_type_id number )
    is
      select ctt.name
      from   cs_transaction_types ctt
      ,      cs_txn_billing_types ctbt
      where  ctt.transaction_type_id = ctbt.transaction_type_id
      and    ctbt.txn_billing_type_id = b_txn_billing_type_id;

    r_uom                     c_uom%rowtype;
    r_agenda_on_duty_item_id  c_agenda_on_duty_item_id%rowtype;
    r_agenda_trip_blg_type_id c_agenda_trip_blg_type_id%rowtype;
    t_agenda_usemileage       number(2);
    t_userdefbuttons          varchar2(2000);
    t_udb_start               number(4);
    t_udb_stop                number(4);
    t_sep                     varchar2(1) := fnd_global.local_chr(2);

  BEGIN
    -- If the PL/SQL table doesn't exist, create it with a single record.
    -- This record can then be filled with the parametervalues.
    if io_param.count < 1
    then
      io_param(1) := null;
    end if;

    io_param(1).primary_key := 1;

    -- Parameters on tab General

    io_param(1).agenda_progressclock
      := query_parameter('agenda_progressclock',1);

    -- Parameters on tab Agenda

    io_param(1).agenda_forceworkform
      := query_parameter('agenda_forceworkform',0);
    io_param(1).agenda_accompletedtask
      := query_parameter('agenda_allowchangescompletedtask',1);
    io_param(1).csf_m_agenda_accompletedtask
      := query_parameter('csf_m_agenda_allowchangescompletedtask',1);
    io_param(1).agenda_allowchangesinpast
      := query_parameter('agenda_allowchangesinpast',0);
    io_param(1).agenda_dayslookback
      := query_parameter('agenda_dayslookback',1);
    io_param(1).agenda_roundedofftime
      := SubStr( query_parameter('agenda_roundedofftime','0:05:00')
               , 3
               , 2
               );
    io_param(1).agenda_refreshwaittime
      := query_parameter('agenda_refreshwaittime',60);

    -- Parameters on tab Items

    t_agenda_usemileage
      := query_parameter('agenda_usemileage',0);
    -- bit 0
    io_param(1).agenda_usemileagestartofday
      := mod(t_agenda_usemileage,2);
    -- bit 1
    if mod(t_agenda_usemileage,4) >= 2
    then
      io_param(1).agenda_usemileagefinishofday := 1;
    else
      io_param(1).agenda_usemileagefinishofday := 0;
    end if;
    -- bit 2
    if mod(t_agenda_usemileage,8) >= 4
    then
      io_param(1).agenda_usemileagestarttask := 1;
    else
      io_param(1).agenda_usemileagestarttask := 0;
    end if;
    -- bit 3
    if mod(t_agenda_usemileage,16) >= 8
    then
      io_param(1).agenda_usemileagefinishtask := 1;
    else
      io_param(1).agenda_usemileagefinishtask := 0;
    end if;

    io_param(1).agenda_mileageuom
      := query_parameter('agenda_mileageuom','-');

    /* For this parameter it's necessary to return the description instead of
       the value */
    open c_uom(io_param(1).agenda_mileageuom);
    fetch c_uom into r_uom;
    if c_uom%found
    then
      io_param(1).agenda_unit_of_measure_tl
        := r_uom.unit_of_measure_tl;
    else
      /* UOM description cannot be found. Return parameter-value. Form
         will have to handle this invalid situation */
      io_param(1).agenda_unit_of_measure_tl
        := io_param(1).agenda_mileageuom;
    end if;
    close c_uom;

    io_param(1).agenda_on_duty_item_id
      := query_parameter('agenda_on_duty_item_id',0);
    io_param(1).csf_m_agenda_on_duty_item_id
      := query_parameter('csf_m_agenda_on_duty_item_id',0);

    /* For these parameters it's necessary to return the description instead of
       the value. Note that the two parameters are presented as a single parameter.
       Therefore the description of only of of them needs to be retrieved.
       The reason for having two parameters is a requirement for palm to have a
       different parametername than laptop. */
    open c_agenda_on_duty_item_id
         ( io_param(1).agenda_on_duty_item_id
         );
    fetch c_agenda_on_duty_item_id into r_agenda_on_duty_item_id;
    if c_agenda_on_duty_item_id%found
    then
      io_param(1).agenda_inventory_item_name_tl
        := r_agenda_on_duty_item_id.concatenated_segments;
    else
      /* UOM translation cannot be found. Return '-'. Form
         will have to handle this invalid situation */
      io_param(1).agenda_inventory_item_name_tl := '-';
    end if;
    close c_agenda_on_duty_item_id;

    io_param(1).agenda_trip_blg_type_id
      := query_parameter('agenda_trip_blg_type_id',0);
    io_param(1).csf_m_agenda_trip_blg_type_id
      := query_parameter('csf_m_agenda_trip_blg_type_id',0);
    /* Add by A. Soykan
       implement business_process_id */
    io_param(1).agenda_trip_process_id
      := query_parameter('agenda_trip_process_id', 0);
    io_param(1).csf_m_agenda_trip_process_id
      := query_parameter('csf_m_agenda_trip_process_id', 0);

    /* For these parameters it's necessary to return the description instead of
       the value. Note that the two parameters are presented as a single parameter.
       Therefore the description of only of of them needs to be retrieved.
       The reason for having two parameters is a requirement from palm to have a
       different parametername than laptop. */
    open c_agenda_trip_blg_type_id
         ( io_param(1).agenda_trip_blg_type_id
         );
    fetch c_agenda_trip_blg_type_id into r_agenda_trip_blg_type_id;
    if c_agenda_trip_blg_type_id%found
    then
      io_param(1).agenda_trip_blg_type_name
        := r_agenda_trip_blg_type_id.name;
    else
      /* Transaction type name cannot be found. Return '-'. Form
         will have to handle this invalid situation */
      io_param(1).agenda_trip_blg_type_name := '-';
    end if;
    close c_agenda_trip_blg_type_id;

    -- Parameters on tab parts.

    io_param(1).parts_allowstocklevelbelowzero
      := query_parameter('parts_allowstocklevelbelowzero',0);
    io_param(1).parts_showtime
      := query_parameter('parts_showtime',0);
    io_param(1).parts_editserialnumber
      := query_parameter('parts_editserialnumber',0);

    -- Parameters on tab SR Explorer

    io_param(1).soexp_addsoh_remote
      := query_parameter('soexp_addsoh_remote',0);
    io_param(1).soexp_editsoh_remote
      := query_parameter('soexp_editsoh_remote',0);
    io_param(1).soexp_addsoa_remote
      := query_parameter('soexp_addsoa_remote',0);
    io_param(1).soexp_editsoa_remote
      := query_parameter('soexp_editsoa_remote',0);
    io_param(1).soexp_standardtaskduration
      := query_parameter('soexp_standardtaskduration','1:00:00');

    -- Parameters on tab Mail

    io_param(1).recipients_boundary
      := query_parameter('recipients_boundary',0);
    io_param(1).csf_m_recipients_boundary
      := query_parameter('csf_m_recipients_boundary',0);
    io_param(1).mail_engbeepunreadmail
      := query_parameter('mail_engbeepunreadmail',1);

    -- Parameters on tab Buttons

    t_userdefbuttons
      := query_parameter('userdefbuttons',    t_sep
                                           || t_sep
                                           || t_sep
                                           || t_sep
                                           || t_sep
                                           || t_sep
                                           || t_sep );
    -- More than once the seperator will be found at the starting
    -- search position. That is not an error. SubStr handles it.
    t_udb_start := 1;
    t_udb_stop := InStr( t_userdefbuttons, t_sep, t_udb_start);
    io_param(1).userdefbutton1 := SubStr( t_userdefbuttons
                                        , t_udb_start
                                        , t_udb_stop - t_udb_start
                                        );
    t_udb_start := t_udb_stop+1;
    t_udb_stop := InStr( t_userdefbuttons, t_sep, t_udb_start);
    io_param(1).userdefbutton2 := SubStr( t_userdefbuttons
                                        , t_udb_start
                                        , t_udb_stop - t_udb_start
                                        );
    t_udb_start := t_udb_stop+1;
    t_udb_stop := InStr( t_userdefbuttons, t_sep, t_udb_start);
    io_param(1).userdefbutton3 := SubStr( t_userdefbuttons
                                        , t_udb_start
                                        , t_udb_stop - t_udb_start
                                        );
    t_udb_start := t_udb_stop+1;
    t_udb_stop := InStr( t_userdefbuttons, t_sep, t_udb_start);
    io_param(1).userdefbutton4 := SubStr( t_userdefbuttons
                                        , t_udb_start
                                        , t_udb_stop - t_udb_start
                                        );
    t_udb_start := t_udb_stop+1;
    t_udb_stop := InStr( t_userdefbuttons, t_sep, t_udb_start);
    io_param(1).userdefbutton5 := SubStr( t_userdefbuttons
                                        , t_udb_start
                                        , t_udb_stop - t_udb_start
                                        );
    t_udb_start := t_udb_stop+1;
    t_udb_stop := InStr( t_userdefbuttons, t_sep, t_udb_start);
    io_param(1).userdefbutton6 := SubStr( t_userdefbuttons
                                        , t_udb_start
                                        , t_udb_stop - t_udb_start
                                        );
    t_udb_start := t_udb_stop+1;
    t_udb_stop := InStr( t_userdefbuttons, t_sep, t_udb_start);
    io_param(1).userdefbutton7 := SubStr( t_userdefbuttons
                                        , t_udb_start
                                        , t_udb_stop - t_udb_start
                                        );
  END query_parameters;

  PROCEDURE update_parameters ( io_param in out nocopy paramtab )
  IS
    /******************************************************
     Created by: T. Voerman, Oracle Nederland

     Date created:

     Purpose: update parametervalues

     Known Limitations:

     Remarks: uses private procedures insert_parameter, update parameter,
              save_parameter_value
    ********************************************************/

    t_csm_onlytodispatchers     number(1);
    t_csm_onlytootherengingroup number(1);
    t_csm_outsideTinoway        number(1);
    t_sep                       varchar2(1) := fnd_global.local_chr(2);

    procedure insert_parameter
    ( i_name  varchar2
    , i_value varchar2 )
    is
      /******************************************************
       Created by: T. Voerman, Oracle Nederland

       Date created:

       Purpose: insert parameter in csf_params

       Known Limitations:

       Remarks:
      ********************************************************/

    begin
      insert into csf_params
      ( PARAM_ID
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_LOGIN
      , NAME
      , VALUE
      )
      values( csf_params_s.nextval
      , sysdate
      , uid
      , sysdate
      , uid
      , 0
      , Upper(i_name)
      , i_value
      );
    end insert_parameter;

    procedure update_parameter
    ( i_name  varchar2
    , i_value varchar2 )
    is
      /******************************************************
       Created by: T. Voerman, Oracle Nederland

       Date created:

       Purpose: update parameter in csf_params

       Known Limitations:

       Remarks:
      ********************************************************/

    begin
      update csf_params par
      set    par.value        = i_value
      ,      last_updated_by  = uid
      ,      last_update_date = sysdate
      where  Upper(par.name)  = Upper(i_name);
    end update_parameter;

    procedure save_parameter_value
    ( i_name  varchar2
    , i_value number )
    is
      /******************************************************
       Created by: T. Voerman, Oracle Nederland

       Date created:

       Purpose: check whether a numeric parameter already exists.
                If so: update the parameter value.
                If not: create the parameter together with it's value.

       Known Limitations:

       Remarks:
      ********************************************************/

      r_read_parameter c_read_parameter%rowtype;
      t_found          boolean;

    begin
      open c_read_parameter(i_name);
      fetch c_read_parameter into r_read_parameter;
      t_found := c_read_parameter%found;
      close c_read_parameter;
      if t_found
      then
        update_parameter( i_name
                        , To_Char(i_value)
                        );
      else
        insert_parameter( i_name
                        , To_Char(i_value)
                        );
      end if;
    end save_parameter_value;

    procedure save_parameter_value
    ( i_name  varchar2
    , i_value varchar2 )
    is
      /******************************************************
       Created by: T. Voerman, Oracle Nederland

       Date created:

       Purpose: check whether a character parameter already exists.
                If so: update the parameter value.
                If not: create the parameter together with it's value.

       Known Limitations:

       Remarks:
      ********************************************************/

      r_read_parameter c_read_parameter%rowtype;
      t_found          boolean;

    begin
      open c_read_parameter(i_name);
      fetch c_read_parameter into r_read_parameter;
      t_found := c_read_parameter%found;
      close c_read_parameter;
      if t_found
      then
        update_parameter( i_name
                        , i_value
                        );
      else
        insert_parameter( i_name
                        , i_value
                        );
      end if;
    end save_parameter_value;

  BEGIN

    -- Parameters on tab General

    save_parameter_value( 'agenda_progressclock'
                          , io_param(1).agenda_progressclock
                          );

    -- Parameters on tab Agenda

    save_parameter_value( 'agenda_forceworkform'
                          , io_param(1).agenda_forceworkform
                          );
    save_parameter_value( 'agenda_allowchangescompletedtask'
                          , io_param(1).agenda_accompletedtask
                          );
    save_parameter_value( 'csf_m_agenda_allowchangescompletedtask'
                          , io_param(1).csf_m_agenda_accompletedtask
                          );
    save_parameter_value( 'agenda_allowchangesinpast'
                          , io_param(1).agenda_allowchangesinpast
                          );
    save_parameter_value( 'agenda_dayslookback'
                          , io_param(1).agenda_dayslookback
                          );
    save_parameter_value( 'agenda_roundedofftime'
                          ,    '0:'
                            || LTrim( To_Char
                                      ( io_param(1).agenda_roundedofftime
                                      , '09'
                                      )
                                    )
                            || ':00'
                          );
    save_parameter_value( 'agenda_refreshwaittime'
                          , io_param(1).agenda_refreshwaittime
                          );
    save_parameter_value( 'agenda_trip_blg_type_id'
                          , io_param(1).agenda_trip_blg_type_id
                          );
    save_parameter_value( 'csf_m_agenda_trip_blg_type_id'
                          , io_param(1).csf_m_agenda_trip_blg_type_id
                          );
    /* Add by A. Soykan
       implement business_process_id */
    save_parameter_value( 'agenda_trip_process_id'
                          , io_param(1).agenda_trip_process_id
                          );
    save_parameter_value( 'csf_m_agenda_trip_process_id'
                          , io_param(1).csf_m_agenda_trip_process_id
                          );

    -- Parameters on tab Items

    save_parameter_value( 'agenda_usemileage'
                          ,   (    io_param(1).agenda_usemileagestartofday )
                            + (2 * io_param(1).agenda_usemileagefinishofday)
                            + (4 * io_param(1).agenda_usemileagestarttask  )
                            + (8 * io_param(1).agenda_usemileagefinishtask )
                          );
    save_parameter_value( 'agenda_mileageuom'
                          , io_param(1).agenda_mileageuom
                          );
    save_parameter_value( 'agenda_on_duty_item_id'
                          , io_param(1).agenda_on_duty_item_id
                          );
    save_parameter_value( 'csf_m_agenda_on_duty_item_id'
                          , io_param(1).csf_m_agenda_on_duty_item_id
                          );
    save_parameter_value( 'parts_allowstocklevelbelowzero'
                          , io_param(1).parts_allowstocklevelbelowzero
                          );
    save_parameter_value( 'parts_showtime'
                          , io_param(1).parts_showtime
                          );
    save_parameter_value( 'parts_editserialnumber'
                          , io_param(1).parts_editserialnumber
                          );

    -- Parameters on tab SO Explorer

    save_parameter_value( 'soexp_addsoh_remote'
                          , io_param(1).soexp_addsoh_remote
                          );
    save_parameter_value( 'soexp_editsoh_remote'
                          , io_param(1).soexp_editsoh_remote
                          );
    save_parameter_value( 'soexp_addsoa_remote'
                          , io_param(1).soexp_addsoa_remote
                          );
    save_parameter_value( 'soexp_editsoa_remote'
                          , io_param(1).soexp_editsoa_remote
                          );
    save_parameter_value( 'soexp_standardtaskduration'
                          , io_param(1).soexp_standardtaskduration
                          );

    -- Parameters on tab Mail

    save_parameter_value( 'recipients_boundary'
                          , io_param(1).recipients_boundary
                          );
    save_parameter_value( 'csf_m_recipients_boundary'
                          , io_param(1).csf_m_recipients_boundary
                          );
    save_parameter_value( 'mail_engbeepunreadmail'
                          , io_param(1).mail_engbeepunreadmail
                          );

    -- It is possible that one or more buttons have no text.
    save_parameter_value( 'userdefbuttons'
                        ,    io_param(1).userdefbutton1 || t_sep
                          || io_param(1).userdefbutton2 || t_sep
                          || io_param(1).userdefbutton3 || t_sep
                          || io_param(1).userdefbutton4 || t_sep
                          || io_param(1).userdefbutton5 || t_sep
                          || io_param(1).userdefbutton6 || t_sep
                          || io_param(1).userdefbutton7 || t_sep
                        );
  END update_parameters;

  PROCEDURE lock_parameters ( io_param in out nocopy  paramtab )
  IS
    /******************************************************
     Created by: T. Voerman, Oracle Nederland

     Date created:

     Purpose: exclusively lock table csf_params.

     Known Limitations:

     Remarks:
    ********************************************************/

  BEGIN
    lock table csf_params
    in exclusive mode
    nowait;
  END lock_parameters;

BEGIN
  io_param(1).primary_key := 1;
END csf_params_PKG;

/
