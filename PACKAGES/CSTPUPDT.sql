--------------------------------------------------------
--  DDL for Package CSTPUPDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPUPDT" AUTHID CURRENT_USER AS
/* $Header: CSTPUPDS.pls 115.5 2003/08/20 02:47:30 ssreddy ship $ */

FUNCTION cstulock (
table_name              in      varchar2,
l_cost_type_id          in      number,
l_organization_id       in      number,
l_list_id               in      number,
err_buf                 out NOCOPY     varchar2,
l_list_id1              in      number      := NULL
)
return integer;

FUNCTION cstuwait_lock(
l_cost_type_id          in      number,
l_organization_id       in      number,
l_list_id               in      number,
err_buf                 out NOCOPY     varchar2,
l_res_list_id           in      number      := NULL,
l_ovh_list_id           in      number      := NULL
)
return integer;

FUNCTION cstudlci(
l_cost_type_id          in      number,
l_organization_id       in      number,
err_buf                 out NOCOPY     varchar2
)
return integer;

FUNCTION cstudlcd(
l_cost_type_id          in      number,
l_organization_id       in      number,
err_buf                 out NOCOPY     varchar2
)
return integer;

FUNCTION cstudlcv(
l_cost_update_id        in      number,
err_buf                 out NOCOPY     varchar2
)
return integer;

FUNCTION cstudlc2(
l_cost_update_id        in      number,
err_buf                 out NOCOPY     varchar2
)
return integer;

FUNCTION cstudlc3(
l_cost_update_id        in      number,
err_buf                 out NOCOPY     varchar2
)
return integer;

SLEEP_TIME    number := 10;
NUM_TRIES     number := 10;

end CSTPUPDT;


 

/
