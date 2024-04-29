--------------------------------------------------------
--  DDL for Package IRC_LOCATION_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_LOCATION_UTILITY" AUTHID CURRENT_USER as
/* $Header: irlocutl.pkh 120.0.12010000.1 2008/07/28 12:48:04 appldev ship $ */
type t_address_line is table of varchar2(250) index by binary_integer;
type t_address_id is table of number index by binary_integer;
--
-- -------------------------------------------------------------------------
-- |---------------------------< address2geometry >------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION address2geometry
(name     varchar2 default null
,street   varchar2 default null
,city     varchar2 default null
,state    varchar2 default null
,zip_code varchar2 default null)
RETURN MDSYS.SDO_GEOMETRY;
-- -------------------------------------------------------------------------
-- |---------------------------< address2geometry >------------------------|
-- -------------------------------------------------------------------------
--
function address2geometry
(name                varchar2 default null
,street              varchar2 default null
,intersecting_street varchar2 default null
,builtup_area        varchar2 default null
,order8_area         varchar2 default null
,order2_area         varchar2 default null
,order1_area         varchar2 default null
,country             varchar2 default null
,postal_code         varchar2 default null
,postal_addon_code   varchar2 default null)
return MDSYS.SDO_GEOMETRY;
-- -------------------------------------------------------------------------
-- |---------------------------< address2geometry >------------------------|
-- -------------------------------------------------------------------------
--
function address2geometry
(address_line1       varchar2
,address_line2       varchar2 default null
,address_line3       varchar2 default null
,address_line4       varchar2 default null
,address_line5       varchar2 default null
,address_line6       varchar2 default null
,address_line7       varchar2 default null
,address_line8       varchar2 default null
,address_line9       varchar2 default null
,country             varchar2 default null)
return MDSYS.SDO_GEOMETRY;
-- -------------------------------------------------------------------------
-- |-------------------------< bulk_address2geometry >---------------------|
-- -------------------------------------------------------------------------
--
procedure bulk_address2geometry
(address_id          in     t_address_id
,address_line1       in     t_address_line
,address_line2       in     t_address_line
,address_line3       in     t_address_line
,address_line4       in     t_address_line
,address_line5       in     t_address_line
,address_line6       in     t_address_line
,address_line7       in     t_address_line
,address_line8       in     t_address_line
,address_line9       in     t_address_line
,country             in     t_address_line
,latitude               out nocopy t_address_id
,longitude              out nocopy t_address_id
,success                out nocopy number
,failure                out nocopy number
);
-- -------------------------------------------------------------------------
-- |---------------------------< address2full >------------------------|
-- -------------------------------------------------------------------------
--
procedure address2full
(address_line1       in     varchar2
,address_line2       in     varchar2 default null
,address_line3       in     varchar2 default null
,address_line4       in     varchar2 default null
,address_line5       in     varchar2 default null
,address_line6       in     varchar2 default null
,address_line7       in     varchar2 default null
,address_line8       in     varchar2 default null
,address_line9       in     varchar2 default null
,country             in     varchar2 default null
,name                   out nocopy varchar2
,house_number           out nocopy varchar2
,street                 out nocopy varchar2
,builtup_area           out nocopy varchar2
,order1_area            out nocopy varchar2
,order2_area            out nocopy varchar2
,order8_area            out nocopy varchar2
,country_name           out nocopy varchar2
,postal_code            out nocopy varchar2
,geometry               out nocopy MDSYS.SDO_GEOMETRY
);
-- -------------------------------------------------------------------------
-- |---------------------------< sdo_distance >----------------------------|
-- -------------------------------------------------------------------------
--  wrapper for sdo_geom.sdo_distance function
--
function sdo_distance
(geom1         in MDSYS.SDO_GEOMETRY
,geom2         in MDSYS.SDO_GEOMETRY
,tolerance     in number) return number;
-- -------------------------------------------------------------------------
-- |---------------------------< sdo_miles >----------------------------|
-- -------------------------------------------------------------------------
--  wrapper for sdo_geom.sdo_distance function, returning miles
--
function sdo_miles
(geom1         in MDSYS.SDO_GEOMETRY
,geom2         in MDSYS.SDO_GEOMETRY
,tolerance     in number) return number;
end irc_location_utility;

/
