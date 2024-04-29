--------------------------------------------------------
--  DDL for Package GHR_462
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_462" AUTHID CURRENT_USER AS
/* $Header: gh462sum.pkh 115.2 2003/07/31 00:13:45 sumarimu noship $ */
--
PROCEDURE populate_sum(
    p_request_id in number
  , p_agency_code   in varchar2
  , p_fiscal_year in number
  , p_from_date   in varchar2
  , p_to_date     in varchar2
  , p_output_fname out nocopy varchar2);

TYPE XMLRec IS RECORD(
TagName VARCHAR2(50),
TagValue VARCHAR2(50));

TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;
vCtr NUMBER;

TYPE P4Matrix IS RECORD(
claims VARCHAR2(30),
bases VARCHAR2(30),
basevalues VARCHAR2(30),
fieldname VARCHAR2(30));

TYPE t_P4Matrix IS TABLE OF P4Matrix INDEX BY BINARY_INTEGER;
v_P4Matrix t_P4Matrix;


TYPE r_temp IS RECORD(
complaint_id NUMBER(15));

TYPE t_temp IS TABLE OF r_temp INDEX BY BINARY_INTEGER;
v_temp t_temp;


-- Procedure to Populate Part1- Precomplaint phase
PROCEDURE populate_part1(
    p_from_date   in date,
	p_to_date     in date,
    p_agency_code   in varchar2);

-- Procedure to populate Part 2- Formal Complaint phase
PROCEDURE populate_part2(
    p_from_date   in date,
	p_to_date     in date,
    p_agency_code   in varchar2);

-- Procedure to populate Part 4- Bases and Issues
PROCEDURE populate_part4(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code   in varchar2);

-- Procedure to populate Part 5- Summary of Closures by statute
PROCEDURE populate_part5(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code   in varchar2);

-- Procedure to populate Part 6- Summary of Closures by Category
PROCEDURE populate_part6(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code   in varchar2);

-- Procedure to populate Part 7- Summary of Complaints closed with corrective action
PROCEDURE populate_part7(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code   in varchar2);

-- Procedure to populate Part 8- Summary of Pending Complaints
PROCEDURE populate_part8(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code   in varchar2);

-- Procedure to populate Part 10- Summary of ADR Program activities - Precomplaint phase
PROCEDURE populate_part10(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code   in varchar2);

-- Procedure to populate Part 11- Summary of ADR Program activities - Formal Complaint phase
PROCEDURE populate_part11(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code   in varchar2);

-- Procedure to Write into XML file
PROCEDURE WritetoXML(
	p_request_id in number,
	p_agency_code   in varchar,
	p_fiscal_year in number,
    p_from_date   in date,
	p_to_date     in date,
	p_output_fname out nocopy varchar2);

PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2);

PROCEDURE PopulatePart4Matrix;
END ghr_462;



 

/
