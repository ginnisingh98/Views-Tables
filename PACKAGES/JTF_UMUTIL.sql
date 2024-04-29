--------------------------------------------------------
--  DDL for Package JTF_UMUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UMUTIL" AUTHID CURRENT_USER as
/* $Header: JTFUMLDS.pls 115.2 2002/02/14 12:09:37 pkm ship     $ */


function usertype_lookup(utype_key varchar2, effective_date date)
  return number;

function subscription_lookup(subscr_key varchar2, effective_date date)
  return number;

function template_lookup(tmpl_key varchar2, effective_date date)
  return number;

function approval_lookup(appr_key varchar2, effective_date date)
  return number;

function approval_lookup_with_check(appr_key varchar2, effective_date date)
  return number;

function subscription_lookup_with_check(subscr_key varchar2, effective_date date)
  return number;

function user_lookup(uname IN varchar2)
  return number;

function date_to_char(inDate IN date)
  return varchar2;


end JTF_UMUTIL;

 

/
