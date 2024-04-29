--------------------------------------------------------
--  DDL for Package FND_FLEX_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_WORKFLOW" AUTHID CURRENT_USER AS
/* $Header: AFFFWKFS.pls 120.1.12010000.1 2008/07/25 14:15:08 appldev ship $ */


TYPE key_flex_type IS RECORD
  (application_id         fnd_application.application_id%TYPE,
   application_short_name fnd_application.application_short_name%TYPE,
   id_flex_code           fnd_id_flexs.id_flex_code%TYPE,
   id_flex_num            fnd_id_flex_structures.id_flex_num%TYPE,
   numof_segments         NUMBER);

PROCEDURE get_key_flex(p_item_type IN VARCHAR2,
		       p_item_key  IN VARCHAR2,
		       px_key_flex IN OUT nocopy key_flex_type);

FUNCTION select_process(appl_short_name IN VARCHAR2,
			code            IN VARCHAR2,
			num             IN NUMBER,
			itemtype        IN VARCHAR2) RETURN VARCHAR2;

FUNCTION initialize(appl_short_name IN VARCHAR2,
		    code            IN VARCHAR2,
		    num             IN NUMBER,
		    itemtype        IN VARCHAR2) RETURN VARCHAR2;

FUNCTION generate(itemtype      IN VARCHAR2,
		  itemkey       IN VARCHAR2,
		  ccid          IN OUT nocopy NUMBER,
		  concat_segs   IN OUT nocopy VARCHAR2,
		  concat_ids    IN OUT nocopy VARCHAR2,
		  concat_descrs IN OUT nocopy VARCHAR2,
		  error_message IN OUT nocopy VARCHAR2) RETURN BOOLEAN;

FUNCTION generate(itemtype        IN VARCHAR2,
		  itemkey         IN VARCHAR2,
		  insert_if_new   IN BOOLEAN,
		  ccid            IN OUT nocopy NUMBER,
		  concat_segs     IN OUT nocopy VARCHAR2,
		  concat_ids      IN OUT nocopy VARCHAR2,
		  concat_descrs   IN OUT nocopy VARCHAR2,
		  error_message   IN OUT nocopy VARCHAR2,
		  new_combination IN OUT nocopy BOOLEAN) RETURN BOOLEAN;

FUNCTION generate_partial(itemtype        IN VARCHAR2,
			  itemkey         IN VARCHAR2,
			  subprocess      IN VARCHAR2,
			  block_activity  IN VARCHAR2,
			  ccid            IN OUT nocopy NUMBER,
			  concat_segs     IN OUT nocopy VARCHAR2,
			  concat_ids      IN OUT nocopy VARCHAR2,
			  concat_descrs   IN OUT nocopy VARCHAR2,
			  error_message   IN OUT nocopy VARCHAR2) RETURN BOOLEAN;

FUNCTION generate_partial(itemtype        IN VARCHAR2,
			  itemkey         IN VARCHAR2,
			  subprocess      IN VARCHAR2,
			  block_activity  IN VARCHAR2,
			  insert_if_new   IN BOOLEAN,
			  ccid            IN OUT nocopy NUMBER,
			  concat_segs     IN OUT nocopy VARCHAR2,
			  concat_ids      IN OUT nocopy VARCHAR2,
			  concat_descrs   IN OUT nocopy VARCHAR2,
			  error_message   IN OUT nocopy VARCHAR2,
			  new_combination IN OUT nocopy BOOLEAN) RETURN BOOLEAN;

PROCEDURE load_concatenated_segments(itemtype      IN VARCHAR2,
				     itemkey       IN VARCHAR2,
				     concat_segs   IN VARCHAR2);

PROCEDURE purge(itemtype       IN VARCHAR2,
		itemkey        IN VARCHAR2);

PROCEDURE debug_on;

PROCEDURE debug_off;

END fnd_flex_workflow;

/
