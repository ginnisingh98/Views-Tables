--------------------------------------------------------
--  DDL for Package PO_HR_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HR_LOCATION" AUTHID CURRENT_USER AS
/* $Header: POXPRPOS.pls 120.3 2007/02/15 20:27:55 dedelgad ship $ */

-- <R12 PO OTM Integration START>: Added overloaded version of get_address
/*******************************************************************
NAME:  get_address

Description : This is a over loaded procedure to orginal procedure.
  	Created as apart of FPJ PO Communication enhancement.

    Referenced by :
    Parameters    :

*******************************************************************/
PROCEDURE get_address
( p_location_id          IN         NUMBER
, x_address_line_1       OUT NOCOPY VARCHAR2
, x_address_line_2       OUT NOCOPY VARCHAR2
, x_address_line_3       OUT NOCOPY VARCHAR2
, x_town_or_city         OUT NOCOPY VARCHAR2
, x_state_or_province    OUT NOCOPY VARCHAR2
, x_postal_code          OUT NOCOPY VARCHAR2
, x_territory_short_name OUT NOCOPY VARCHAR2
, x_iso_territory_code   OUT NOCOPY VARCHAR2
);
-- <R12 PO OTM Integration END>

  PROCEDURE get_address
     ( x_location_id        IN  Number,
       Address_line_1       OUT NOCOPY Varchar2,
       Address_line_2       OUT NOCOPY Varchar2,
       Address_line_3       OUT NOCOPY Varchar2,
       Territory_short_name OUT NOCOPY VArchar2,
       Address_info         OUT NOCOPY  Varchar2 );

/*******************************************************************
  NAME:  get_address

  Description : This is a over loaded procedure to orginal procedure.
	Created as apart of FPJ PO Communication enhancement.

  Referenced by :
  parameters    :

  CHANGE History: Created     MANRAM
                  bug:3463617 - Added new out variable x_address_line_4
--bug3438608 added the out variables x_town_or_city
--x_postal_code and x_state_or_province
*******************************************************************/
PROCEDURE get_address
    ( p_location_id		IN  Number,
      x_address_line_1		OUT NOCOPY Varchar2,
      x_address_line_2		OUT NOCOPY Varchar2,
      x_address_line_3		OUT NOCOPY Varchar2,
      x_territory_short_name	OUT NOCOPY VArchar2,
      x_address_info		OUT NOCOPY Varchar2,
      x_location_name		OUT NOCOPY  Varchar2,
      x_contact_phone		OUT NOCOPY  Varchar2,
      x_contact_fax		OUT NOCOPY  Varchar2,
      x_address_line_4		OUT NOCOPY  Varchar2,
      x_town_or_city		OUT NOCOPY HR_LOCATIONS.town_or_city%type ,
      x_postal_code		OUT NOCOPY HR_LOCATIONS.postal_code%type,
      x_state_or_province	OUT NOCOPY varchar2 );

--Bug#3580225 Start --
/************************************************************************************
  NAME:  get_alladdress_lines

  Description : This procedure  has the same code as that of over loaded procedure of
                get_address and the code to retrieve all the address details from
		HR_LOCATIONS and HZ_LOCATIONS. The fields used in HR_LOCATIONS table is
		retreived using fnd_dflex package and for HZ_LOCATIONS,
		HZ_FORMAT_PUB.FORMAT_ADDRESS procedure is used.

  Referenced by :
  parameters    :

  CHANGE History: Created     MANRAM

*******************************************************************/
PROCEDURE get_alladdress_lines
    ( p_location_id		IN  Number,
      x_address_line_1		OUT NOCOPY Varchar2,
      x_address_line_2		OUT NOCOPY Varchar2,
      x_address_line_3		OUT NOCOPY Varchar2,
      x_territory_short_name	OUT NOCOPY VArchar2,
      x_address_info		OUT NOCOPY Varchar2,
      x_location_name		OUT NOCOPY  Varchar2,
      x_contact_phone		OUT NOCOPY  Varchar2,
      x_contact_fax		OUT NOCOPY  Varchar2,
      x_address_line_4		OUT NOCOPY  Varchar2,
      x_town_or_city		OUT NOCOPY HR_LOCATIONS.town_or_city%type ,
      x_postal_code		OUT NOCOPY HR_LOCATIONS.postal_code%type,
      x_state_or_province	OUT NOCOPY varchar2 );


/************************************************************************************
  vchar_array is a type of VARRAY of size 20. This holds the data of type varchar2.
*************************************************************************************/

TYPE vchar_array IS VARRAY(20) OF VARCHAR2(240);

/************************************************************************************
  address is a PL/SQL table of po_address_details_gt global temp table rowtype .
*************************************************************************************/

TYPE address IS TABLE OF po_address_details_gt%rowtype INDEX BY BINARY_INTEGER;


/************************************************************************************
  NAME:  populate_gt

  Description : This procedure populates the global temp table from PL/SQL table.
                This procedure is called from PO_COMMUNICATION_PVT.POXMLGEN function.

  Referenced by :
  parameters    : None

  CHANGE History: Created     MANRAM

*******************************************************************/
procedure populate_gt ;



/*******************************************************************************
 addr_prompt_query_rec is of type record with address style, address prompt list
 and query as columns.
 CHANGE History: 1) bug#3622675: PO_HR_LOCATION package is erroring out with
 PLS-00507: a PLSQL Table may not contain a table or a record with composite
 fields when compliled in 8i data base. Replaced the array list l_addr_prompts_array
 with 20 varibales which holds the prompt names.
*******************************************************************************/
TYPE addr_prompt_query_rec IS RECORD(address_style hr_locations.style%type,
					addr_label_1	varchar2(240),
					addr_label_2	varchar2(240),
					addr_label_3	varchar2(240),
					addr_label_4	varchar2(240),
					addr_label_5	varchar2(240),
					addr_label_6	varchar2(240),
					addr_label_7	varchar2(240),
					addr_label_8	varchar2(240),
					addr_label_9	varchar2(240),
					addr_label_10	varchar2(240),
					addr_label_11	varchar2(240),
					addr_label_12	varchar2(240),
					addr_label_13	varchar2(240),
					addr_label_14	varchar2(240),
					addr_label_15	varchar2(240),
					addr_label_16	varchar2(240),
					addr_label_17	varchar2(240),
					addr_label_18	varchar2(240),
					addr_label_19	varchar2(240),
					addr_label_20	varchar2(240),
					query varchar2(4000) );


/*********************************************************************************
 This is a PL/SQL table of addr_prompt_query_rec record type.
 This PL/SQL table is used to store the style code, address prompt List
 and the select query that is framed after retreiving values from descriptive flex
 fields. style code is unique field. If the style code for which values are to be
 retrieved from descriptive flex fields is exists in this table then the values
 in the PL/SQL table are used, other wise it will call fnd_dflex package.
*********************************************************************************/
TYPE addr_prompt_query IS TABLE OF addr_prompt_query_rec index by binary_integer;

--Bug#3580225 --
-- HTML Orders R12
FUNCTION get_formatted_address(p_location_id IN NUMBER)
RETURN VARCHAR2;

  END PO_HR_LOCATION;

/
