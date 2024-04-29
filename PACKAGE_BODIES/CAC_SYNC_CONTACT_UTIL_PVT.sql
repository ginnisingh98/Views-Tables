--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_CONTACT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_CONTACT_UTIL_PVT" as
/* $Header: cacvscub.pls 120.1 2005/07/02 02:20:51 appldev noship $ */

    FUNCTION FORMAT_PHONE
    ( p_country_code         IN   VARCHAR2
    , p_area_code            IN   VARCHAR2
    , p_phone_number         IN   VARCHAR2
    , p_phone_extension      IN   VARCHAR2
    , p_delimit_country      IN   VARCHAR2
    , p_delimit_area_code    IN   VARCHAR2
    , p_delimit_phone_number IN   VARCHAR2
    , p_delimit_extension    IN   VARCHAR2
    )
    RETURN VARCHAR2
    IS
        l_raw_phone_number VARCHAR2(100);
    BEGIN
        cac_sync_contact_util_pvt.log(p_message=>'Entering FORMAT_PHONE...',
                                      p_msg_level=>fnd_log.level_procedure,
                                      p_module_prefix=>'FORMAT_PHONE');

        IF p_country_code IS NOT NULL THEN
          l_raw_phone_number := NVL(p_delimit_country,'+') || p_country_code;
        END IF;

        IF p_area_code IS NOT NULL THEN
          IF p_delimit_area_code = '( )' THEN
             IF l_raw_phone_number IS NOT NULL THEN
                 l_raw_phone_number := l_raw_phone_number || ' (' || p_area_code || ') ';
             ELSE
                 l_raw_phone_number := '(' || p_area_code || ') ';
             END IF;
          ELSE
             IF l_raw_phone_number IS NOT NULL THEN
                 l_raw_phone_number := l_raw_phone_number || NVL(p_delimit_area_code,'-') || p_area_code;
             ELSE
                 l_raw_phone_number := p_area_code;
             END IF;
          END IF;
        END IF;

        IF p_phone_number IS NOT NULL THEN
          IF l_raw_phone_number IS NOT NULL THEN
            l_raw_phone_number := l_raw_phone_number ||
                                  NVL(p_delimit_phone_number,'-') || p_phone_number;
          ELSE
            l_raw_phone_number := p_phone_number;
          END IF;
        END IF;

        IF p_phone_extension IS NOT NULL THEN
          IF p_delimit_extension IS NULL THEN
            l_raw_phone_number := l_raw_phone_number ||
                                  ' ' || p_phone_extension;
          ELSIF p_delimit_extension = '< >' THEN
            l_raw_phone_number := l_raw_phone_number || ' <' ||
                                  p_phone_extension || '>';
          ELSIF p_delimit_extension = '( )' THEN
            l_raw_phone_number := l_raw_phone_number || ' (' ||
                                  p_phone_extension || ')';
          ELSE
            l_raw_phone_number := l_raw_phone_number ||
                                  p_delimit_extension || p_phone_extension;
          END IF;
        END IF;

        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            cac_sync_contact_util_pvt.log(p_message=>'Returning a value '||l_raw_phone_number||'...',
                                          p_msg_level=>fnd_log.level_procedure,
                                          p_module_prefix=>'FORMAT_PHONE');
        END IF;

        RETURN l_raw_phone_number;

    END FORMAT_PHONE;

    PROCEDURE LOG
    (p_message        IN     VARCHAR2,
     p_msg_level      IN     NUMBER,
     p_prefix         IN     VARCHAR2,
     p_module_prefix  IN     VARCHAR2,
     p_module         IN     VARCHAR2
    )
    IS
        l_message       VARCHAR2(4000);
        l_module_prefix VARCHAR2(255);
        l_module        VARCHAR2(80);
        l_module_text   VARCHAR2(255);
    BEGIN
        IF  p_msg_level >= fnd_log.g_current_runtime_level
        THEN
            IF p_module_prefix IS NULL
            THEN
                l_module_prefix := 'CAC_SYNC_CONTACT';
            ELSE
                l_module_prefix := p_module_prefix;
            END IF;

            IF p_module IS NULL
            THEN
                l_module := 'JTF';
            ELSE
                l_module := p_module;
            END IF;

            l_module_text := SUBSTRB('jtf.cac.sync.contact.plsql.'||l_module_prefix||'.'||l_module,1,255);

            IF p_prefix IS NOT NULL
            THEN
              l_message := substrb(p_prefix||'-'||p_message, 1, 4000);
            ELSE
              l_message := substrb(p_message,1,4000);
            END IF;

            fnd_log.string(p_msg_level, l_module_text, l_message);
        END IF;
    END LOG;

END CAC_SYNC_CONTACT_UTIL_PVT;

/
