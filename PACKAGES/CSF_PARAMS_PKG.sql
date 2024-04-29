--------------------------------------------------------
--  DDL for Package CSF_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_PARAMS_PKG" AUTHID CURRENT_USER AS
/* $Header: CSFCPARS.pls 115.11.11510.2 2004/06/24 04:35:07 srengana ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):='CSF_PARAMS_PKG';

type paramrec is
record
( primary_key                          number(1)
, agenda_progressclock                 number(1)
, agenda_forceworkform                 number(1)
, agenda_accompletedtask               number(1)
, csf_m_agenda_accompletedtask         number(1)
, agenda_allowchangesinpast            number(1)
, agenda_dayslookback                  number(6)
, agenda_roundedofftime                number(2)
, agenda_refreshwaittime               number(6)
, agenda_usemileagestartofday          number(1)
, agenda_usemileagefinishofday         number(1)
, agenda_usemileagestarttask           number(1)
, agenda_usemileagefinishtask          number(1)
, agenda_mileageuom                    varchar2(3)
, agenda_unit_of_measure_tl            varchar2(25)
, agenda_on_duty_item_id               number
, csf_m_agenda_on_duty_item_id         number
, agenda_inventory_item_name_tl        varchar2(40)
, agenda_trip_blg_type_id              number
, csf_m_agenda_trip_blg_type_id        number
, agenda_trip_blg_type_name            varchar2(30)
, parts_allowstocklevelbelowzero       number(1)
, parts_showtime                       number(1)
, parts_editserialnumber               number(1)
, soexp_addsoh_remote                  number(1)
, soexp_editsoh_remote                 number(1)
, soexp_addsoa_remote                  number(1)
, soexp_editsoa_remote                 number(1)
, soexp_standardtaskduration           varchar2(7)
, recipients_boundary                  number(1)
, csf_m_recipients_boundary            number(1)
, mail_engbeepunreadmail               number(1)
, userdefbutton1                       varchar2(2000)
, userdefbutton2                       varchar2(2000)
, userdefbutton3                       varchar2(2000)
, userdefbutton4                       varchar2(2000)
, userdefbutton5                       varchar2(2000)
, userdefbutton6                       varchar2(2000)
, userdefbutton7                       varchar2(2000)
, agenda_trip_process_id               number
, csf_m_agenda_trip_process_id         number
);

type paramtab is
table of paramrec
index by binary_integer;

cursor c_read_parameter
(b_name varchar2
)
is
select par.param_id
,      par.value
from   csf_params par
where  Upper(par.name) = Upper(b_name);

io_param paramtab;

function query_parameter
( i_name varchar2
, i_default_value number
)
return number;

function query_parameter
( i_name varchar2
, i_default_value varchar2
)
return varchar2;

procedure query_parameters
( io_param in out paramtab
);

procedure update_parameters
( io_param in out paramtab
);

procedure lock_parameters
( io_param in out paramtab
);

end CSF_PARAMS_PKG;

 

/
