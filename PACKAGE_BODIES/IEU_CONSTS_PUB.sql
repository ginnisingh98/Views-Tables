--------------------------------------------------------
--  DDL for Package Body IEU_CONSTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_CONSTS_PUB" AS
/* $Header: IEUCNSTB.pls 120.1 2006/02/02 03:36:13 nsardana noship $ */


begin

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_INBOUND_TELEPHONY
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_INBOUND_TELEPHONY;  -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_INBOUND_EMAIL
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_INBOUND_EMAIL; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_OUTBOUND_TELEPHONY
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_OUTBOUND_TELEPHONY; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_ADV_OUTB_TELEPHONY
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_ADV_OUTB_TELEPHONY; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_OUTBOUND_EMAIL
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_OUTBOUND_EMAIL; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_WEB_CALLBACK
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_WEB_CALLBACK; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_WEB_COLLABORATION
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_WEB_COLLABORATION; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_DIRECT_EMAIL
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_DIRECT_EMAIL; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_BLENDED
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_BLENDED; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        TYPE_ID
      INTO
        G_STID_UWQ
      FROM
        IEO_SVR_TYPES_B
      WHERE
        TYPE_UUID = G_STUUID_UWQ;
  exception
    when others then
      null;
  end;

  begin
    SELECT
      DISTINCT
        MEDIA_TYPE_ID
      INTO
        G_MTID_ACQUIRED_EMAIL
      FROM
        IEU_UWQ_MEDIA_TYPES_B
      WHERE
        MEDIA_TYPE_UUID = G_MTUUID_ACQUIRED_EMAIL; -- Niraj, Bug 4998176, Replaced value by Variable
  exception
    when others then
      null;
  end;

end IEU_CONSTS_PUB;

/
