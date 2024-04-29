--------------------------------------------------------
--  DDL for Package JG_ZZ_AMOUNT_IN_LETTERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_AMOUNT_IN_LETTERS" AUTHID CURRENT_USER AS
/* $Header: jgzztrls.pls 115.13 2002/10/17 23:21:15 ashrivat ship $ */

TYPE numbers IS TABLE OF VARCHAR2(50)INDEX BY BINARY_INTEGER;
NumberList numbers;

TYPE thousands IS TABLE OF VARCHAR2(50)INDEX BY BINARY_INTEGER;
ThousandList thousands;

-- Number de niveaux defined by group of thousands (milliers)
g_level NUMBER := 4;

-- Initialization de variables
procedure fr_init;
procedure it_init;
procedure sp_init;

function hundreds(p_nb_char IN VARCHAR2 ) return VARCHAR2;

function litteral(p_number IN NUMBER, p_decimal IN BOOLEAN, p_lang IN VARCHAR2) return VARCHAR2;

function litteral_amount(p_number IN NUMBER, p_lang IN VARCHAR2) return VARCHAR2;

function it_exceptions(p_litteral IN VARCHAR2 ) return VARCHAR2;

function sp_exceptions(p_litteral IN VARCHAR2 ) return VARCHAR2;

function fr_exceptions(p_litteral IN VARCHAR2 ) return VARCHAR2;

function it_plural (p_litteral IN VARCHAR2 ) return VARCHAR2;

function fr_plural (p_litteral IN VARCHAR2 ) return VARCHAR2;

function sp_plural (p_litteral IN VARCHAR2 ) return VARCHAR2;

function fr_currency (p_litteral IN VARCHAR2, p_decimal IN BOOLEAN) return VARCHAR2;

end JG_ZZ_AMOUNT_IN_LETTERS ;


 

/
