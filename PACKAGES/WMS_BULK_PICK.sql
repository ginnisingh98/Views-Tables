--------------------------------------------------------
--  DDL for Package WMS_BULK_PICK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_BULK_PICK" AUTHID CURRENT_USER AS
/* $Header: WMSBKPIS.pls 120.0.12010000.1 2008/07/28 18:32:13 appldev ship $*/

--
-- File        : WMSBKPIS.pls
-- Content     : WMS_bulk_pick package specification
-- Description : WMS bulk picking API for mobile application
-- Notes       :
-- Modified    : 07/30/2003 jali created
--

TYPE bulk_input_rec IS RECORD
                 (organization_id NUMBER
                 ,start_mo_request_number    VARCHAR2(30) :=null
                 ,end_mo_request_number      VARCHAR2(30) :=null
                 ,start_release_date DATE :=null
   ,end_release_date DATE :=null
   ,subinventory_code  VARCHAR2(30)
   ,item_id            NUMBER := null
   ,delivery_id NUMBER := null
   ,trip_id NUMBER := null
   ,only_sub_item NUMBER := null);


--
PROCEDURE wms_concurrent_bulk_process(
                 errbuf                    OUT    NOCOPY VARCHAR2
      ,retcode                   OUT    NOCOPY NUMBER
                ,p_organization_id    IN NUMBER
          ,p_start_mo_request_number  IN  VARCHAR2 :=null
  ,p_end_mo_request_number   IN VARCHAR2  :=null
  ,p_start_release_date IN VARCHAR2 :=null
  ,p_end_release_date IN VARCHAR2 :=null
  ,p_subinventory_code IN VARCHAR2 :=null
  ,p_item_id            IN NUMBER := null
  ,p_delivery_id IN NUMBER := null
  ,p_trip_id IN NUMBER := null
  ,p_only_sub_item IN NUMBER := null);


PROCEDURE bulk_pick(p_temp_id            IN NUMBER,
                   p_txn_hdr_id         IN NUMBER,
                   p_org_id             IN NUMBER,
                   p_multiple_pick      IN VARCHAR2 := 'N', -- to indicate if this is multiple pick or not
     p_exception          IN VARCHAR2 := null, -- to indicate if this is over picking or not
     p_lot_controlled      IN VARCHAR2 := 'N',
                   p_user_id            IN NUMBER,
                   p_employee_id        IN NUMBER,
                   p_reason_id          IN NUMBER,
                   x_new_txn_hdr_id     OUT NOCOPY NUMBER,
                   x_return_status      OUT NOCOPY VARCHAR2,
                   x_msg_count          OUT NOCOPY NUMBER,
                   x_msg_data           OUT NOCOPY VARCHAR2);


END wms_bulk_pick;


/
