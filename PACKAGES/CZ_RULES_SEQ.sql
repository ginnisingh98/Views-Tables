--------------------------------------------------------
--  DDL for Package CZ_RULES_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_RULES_SEQ" AUTHID CURRENT_USER AS
/*	$Header: czrseqs.pls 115.10 2002/12/03 14:53:34 askhacha ship $		*/

NULL_       CONSTANT INTEGER:=-1;
YES_FLAG    CONSTANT VARCHAR2(1):='1';
NO_FLAG     CONSTANT VARCHAR2(1):='0';

PROCEDURE 	RemoveFromSequence
(p_rule_sequence_id     IN    INTEGER,	              --ID of the rule sequence
 p_model_id             IN    INTEGER,	              --ID of the model
 p_rule_id              IN    INTEGER,	              --ID of the rule which was removed
 p_out_err              OUT NOCOPY   INTEGER ,	              --err flag
 deleted_flag           IN    VARCHAR2 -- DEFAULT '0');    -- flag if the rule was logically deleted
);

PROCEDURE 	MoveInSequence
(p_rule_sequence_id     IN	INTEGER,	              --ID of the rule sequence
 p_model_id             IN	INTEGER,	              --ID of the model
 p_rule_id	            IN	INTEGER,	              --ID of the rule which is moved within the sequence
 p_new_sequence         IN	INTEGER,	              --New sequence number of the moved rule
 p_out_err                OUT NOCOPY INTEGER);	              --err flag

PROCEDURE 	ChangeEffectivity
(p_rule_sequence_id 	IN	INTEGER,	              --ID of the rule sequence
 p_model_id	      	IN	INTEGER,	              --ID of the model
 p_rule_id	      	IN	INTEGER,	              --ID of the rule whose effectivity changed
 p_out_err	       	  OUT NOCOPY INTEGER,	              --err flag
 p_eff_start_date		IN	DATE DEFAULT NULL,	  -- New start date
 p_eff_end_date		IN	DATE DEFAULT NULL,	  --New end date
 p_eff_set_id		IN	INTEGER -- DEFAULT -1);	  --New effectivity set ID
);

PROCEDURE 	PropagateEffectivitySetChange
(p_effectivity_set_id	IN 	INTEGER,                  --ID of the effectivity set
 p_new_start_date      	IN	DATE,                     --new start date
 p_new_end_date		IN	DATE,		              --new end date
 p_out_err		        OUT NOCOPY INTEGER);                 --Err flag

END;

 

/
