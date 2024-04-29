--------------------------------------------------------
--  DDL for Package Body CCT_MEDIA_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_MEDIA_TYPES_PUB" AS
/* $Header: cctpmtb.pls 115.2 2003/02/19 02:45:35 svinamda noship $*/

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'CCT_MEDIA_TYEPS_PUB';

FUNCTION GET_UWQ_MEDIA_TYPE_ID
(
    p_item_type    IN NUMBER
)
RETURN NUMBER IS
BEGIN
    --dbms_output.put_line('CCT_MEDIA_TYPES_PUB.GET_UWQ_MEDIA_TYPE_ID:'
        --|| ' p_item_type = ' || p_item_type);

    if (p_item_type = G_BASIC_WEB_CALLBACK)
        then return G_UWQ_BASIC_WEB_CALLBACK;
    elsif (p_item_type = G_BASIC_INBOUND_TELE)
        THEN  return G_UWQ_BASIC_INBOUND_TELE;
    elsif (p_item_type = G_INBOUND_TELE)
        THEN return G_UWQ_INBOUND_TELE;
    elsif (p_item_type = G_WEB_CALLBACK)
        THEN return G_UWQ_WEB_CALLBACK;
    elsif (p_item_type = G_WEB_COLLAB)
        THEN return G_UWQ_WEB_COLLAB;
    elsif (p_item_type = G_INBOUND_EMAIL)
        THEN return G_UWQ_INBOUND_EMAIL;
    ELSE return -1;
    end if;

END GET_UWQ_MEDIA_TYPE_ID;

END CCT_MEDIA_TYPES_PUB;

/
