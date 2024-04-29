--------------------------------------------------------
--  DDL for Package PON_OPEN_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_OPEN_INTERFACE_PUB" AUTHID CURRENT_USER as
/* $Header: PON_OPEN_INTERFACE_PUB.pls 120.1.12010000.3 2013/08/15 12:22:24 irasoolm noship $ */

g_fnd_debug          CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name           CONSTANT VARCHAR2(50) := 'PON_OPEN_INTERFACE_PUB';
g_module_prefix      CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

PROCEDURE create_negotiations(
                              EFFBUF           OUT NOCOPY VARCHAR2,
                              RETCODE          OUT NOCOPY VARCHAR2,
                              p_group_batch_id  IN NUMBER
                              );

PROCEDURE print_log(p_message IN VARCHAR2);

TYPE vs IS TABLE OF VARCHAR2(20);

END PON_OPEN_INTERFACE_PUB;

/
