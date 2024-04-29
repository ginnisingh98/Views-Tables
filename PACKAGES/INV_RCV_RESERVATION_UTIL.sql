--------------------------------------------------------
--  DDL for Package INV_RCV_RESERVATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_RESERVATION_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVRUTLS.pls 120.1.12000000.1 2007/01/17 16:29:54 appldev ship $*/

PROCEDURE update_wdd
  (x_return_status OUT NOCOPY 	VARCHAR2
   ,x_msg_count    OUT NOCOPY 	NUMBER
   ,x_msg_data     OUT NOCOPY 	VARCHAR2
   ,p_wdd_id           IN NUMBER
   ,p_released_status IN VARCHAR2
   ,p_mol_id          IN NUMBER
   );

PROCEDURE split_wdd
  (x_return_status OUT NOCOPY 	VARCHAR2
   ,x_msg_count    OUT NOCOPY 	NUMBER
   ,x_msg_data     OUT NOCOPY 	VARCHAR2
   ,x_new_wdd_id   OUT NOCOPY   NUMBER
   ,p_wdd_id       IN           NUMBER
   ,p_new_mol_id   IN           NUMBER
   ,p_qty_to_splt  IN           NUMBER
   );

 PROCEDURE maintain_reservations
  (x_return_status OUT NOCOPY 	VARCHAR2
   ,x_msg_count    OUT NOCOPY 	NUMBER
   ,x_msg_data     OUT NOCOPY 	VARCHAR2
   ,x_mol_tb       OUT NOCOPY   inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   ,p_cas_mol_tb   IN  inv_rcv_integration_pvt.cas_mol_rec_tb_tp
   );

END INV_RCV_RESERVATION_UTIL;


 

/
