--------------------------------------------------------
--  DDL for Package QA_SAMPLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SAMPLING_PKG" AUTHID CURRENT_USER AS
/* $Header: qasampls.pls 120.1.12010000.1 2008/07/25 09:20:40 appldev ship $ */


custom_sampling_plan		CONSTANT NUMBER       := 1;
normal_sampling_plan		CONSTANT NUMBER       := 2;
tighten_sampling_plan		CONSTANT NUMBER       := 3;
reduced_sampling_plan		CONSTANT NUMBER       := 4;
double_sampling_plan		CONSTANT NUMBER       := 5;
multiple_sampling_plan		CONSTANT NUMBER       := 6;
TYPE PlanArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--
-- modified default value from -1 to null per coding standard
-- jezheng
-- Wed Nov 27 15:11:53 PST 2002
--

procedure eval_rcv_sampling_plan (
			p_collection_id IN NUMBER,
			p_organization_id	IN number,
			p_lot_size	in number,
			p_item_id	in number default null,
			p_item_category_id in number default null,
			p_item_revision	in varchar2 default null,
			p_vendor_id	in number default null,
			p_vendor_site_id in number default null,
			p_project_id	in number default null,
			p_task_id	in number default null,
			p_sampling_flag	out NOCOPY varchar2);

procedure set_sample_size(
			p_sampling_plan_id in number,
			p_collection_id in number,
			p_collection_plan_id in number,
			p_lot_size in number,
			p_sample_size out NOCOPY number);

--
-- Bug 6129041
-- Added one IN parameter p_item_id which defaults to NULL
-- skolluku Wed Jul 11 03:24:14 PDT 2007
--
procedure get_plan_result(
			p_collection_id in number,
			p_coll_plan_id in number,
			out_plan_insp_result out NOCOPY varchar2,
                        p_item_id in number DEFAULT NULL);

procedure get_lot_result(
			p_collection_id in number,
			lot_insp_result out NOCOPY varchar2);

procedure launch_shipment_action(
    p_po_txn_processor_mode IN VARCHAR2,
    p_po_group_id IN NUMBER,
    p_collection_id IN NUMBER,
    p_employee_id IN NUMBER,
    p_transaction_id IN NUMBER,
    p_uom IN VARCHAR2,
    p_transaction_date IN DATE,
    p_created_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_last_update_login IN NUMBER);

function is_sampling( p_collection_id in number ) return varchar2;

procedure launch_workflow(
			p_criteria_id IN NUMBER,
			p_coll_plan_id IN NUMBER,
			p_wf_item_key OUT NOCOPY NUMBER);

--
-- Bug 6129041
-- Added two IN parameters p_org_id and p_item which default to null
-- skolluku Wed Jul 11 03:24:14 PDT 2007
--
procedure calculate_lot_result(p_collection_id IN  NUMBER,
                               p_plan_ids      IN  VARCHAR2,
                               x_lot_result    OUT NOCOPY VARCHAR2,
                               x_rej_qty       OUT NOCOPY NUMBER,
                               x_acc_qty       OUT NOCOPY NUMBER,
                               p_org_id        IN  NUMBER DEFAULT NULL,
                               p_item          IN  VARCHAR2 DEFAULT NULL);


procedure eval_rcv_sampling_plan (
                        p_collection_id    IN NUMBER,
                        p_plan_id_list     IN VARCHAR2,
                        p_org_id           IN NUMBER,
                        p_lot_size         IN NUMBER,
                        p_lpn_id           IN NUMBER,
                        p_item             IN VARCHAR2,
                        p_item_id          IN NUMBER,
                        p_item_cat         IN VARCHAR2,
                        p_item_category_id IN NUMBER,
                        p_item_rev         IN VARCHAR2,
                        p_vendor           IN VARCHAR2,
                        p_vendor_id        IN NUMBER,
                        p_vendor_site      IN VARCHAR2,
                        p_vendor_site_id   IN NUMBER,
                        p_project_id       IN NUMBER DEFAULT NULL,
                        p_task_id          IN NUMBER DEFAULT NULL,
                        x_sampling_flag    OUT NOCOPY VARCHAR2);

--
-- Bug 3096256. Added the below procedure for RCV/WMS Merge.
-- This procedure inserts the detailed Inspection results onto
-- qa_insp_collections_dtl_temp. This enables unit wise inspection
-- with LPN and at Lot/Serial levels.
-- Called from launch_shipment_action_int() of QA_SAMPLING_PKG and
-- QA_SKIPLOT_RES_ENGINE.
-- kabalakr Fri Aug 29 09:06:28 PDT 2003.
--

PROCEDURE post_insp_coll_details(p_collection_id IN NUMBER);


END; -- End QA_SAMPLING_PKG


/
