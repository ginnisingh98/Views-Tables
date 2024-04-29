--------------------------------------------------------
--  DDL for Package Body INV_STAGED_RESERVATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_STAGED_RESERVATION_UTIL" AS
/* $Header: INVRSV9B.pls 120.1 2005/06/20 11:27:20 appldev ship $*/
--
 g_pkg_name CONSTANT VARCHAR2(30) := 'INV_STAGED_RESERVATION_UTIL';
--
PROCEDURE query_staged_flag
  ( x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_staged_flag         OUT NOCOPY VARCHAR2,
    p_reservation_id      IN  NUMBER)
is
     l_api_name             CONSTANT VARCHAR2(30) := 'query_staged_flag';
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SAVEPOINT query_stage_sa;

   select nvl(staged_flag,'N')
   into x_staged_flag
   from mtl_reservations
   where reservation_id = p_reservation_id;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO query_stage_sa;
        x_return_status := fnd_api.g_ret_sts_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO query_stage_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
   WHEN OTHERS THEN
        ROLLBACK TO query_stage_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END query_staged_flag;

PROCEDURE update_staged_flag
  ( x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_reservation_id      IN  NUMBER,
    p_staged_flag         IN  VARCHAR2)
is
     l_api_name             CONSTANT VARCHAR2(30) := 'update_staged_flag';
     l_ship_ready_flag      NUMBER;      -- Bug #2816312
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;
   -- Bug #2816312. +5 lines.
   -- Also updating the ship_ready_flag along with the staged_flag.
   IF p_staged_flag = 'Y' THEN
      l_ship_ready_flag := 1;
   ELSIF (p_staged_flag = 'N' OR p_staged_flag is null) THEN
      l_ship_ready_flag := 2;
   END IF;

   SAVEPOINT update_stage_sa;

   update mtl_reservations
   set staged_flag = p_staged_flag
      ,ship_ready_flag = l_ship_ready_flag -- Bug #2816312
   where reservation_id = p_reservation_id;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO update_stage_sa;
        x_return_status := fnd_api.g_ret_sts_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO update_stage_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
   WHEN OTHERS THEN
        ROLLBACK TO update_stage_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

END update_staged_flag;
END inv_staged_reservation_util;

/
