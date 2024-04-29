--------------------------------------------------------
--  DDL for Package Body OE_VIEW_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VIEW_FUNCTIONS" AS
--$Header: OEXVIFNB.pls 120.0 2005/05/31 23:28:21 appldev noship $
FUNCTION GET_AGREEMENT_REVISION
(
  p_Agreement_Name  Varchar2,
  p_revision        Varchar2
)
RETURN Varchar2  is
 x_agreement_revision varchar2(2000);

BEGIN
  fnd_message.set_name('ONT','ONT_CONCAT_AGREEMENT_REVISION');
  fnd_message.set_token('AGREEMENT' , p_Agreement_Name);
  fnd_message.set_token('REVISION' , p_revision);
  x_agreement_revision:=FND_MESSAGE.GET;
  return(x_agreement_revision);
EXCEPTION
WHEN OTHERS  THEN
 return(null);

END GET_AGREEMENT_REVISION;

END OE_VIEW_FUNCTIONS;

/
