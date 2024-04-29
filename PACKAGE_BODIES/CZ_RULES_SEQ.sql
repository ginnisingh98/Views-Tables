--------------------------------------------------------
--  DDL for Package Body CZ_RULES_SEQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_RULES_SEQ" AS
/*	$Header: czrseqb.pls 115.26 2004/06/07 16:02:13 rheramba ship $		*/

GLOBAL_RUN_ID INTEGER:=0;
EPOCH_BEGIN   DATE:=CZ_UTILS.EPOCH_BEGIN_;
EPOCH_END     DATE:=CZ_UTILS.EPOCH_END_;
NULL_VALUE    CONSTANT INTEGER:=-1;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE LOG_REPORT
(p_caller        IN VARCHAR2,
 p_error_message IN VARCHAR2) IS

   l_return BOOLEAN;

BEGIN
   l_return := cz_utils.log_report(Msg        => p_error_message,
                                   Urgency    => 1,
                                   ByCaller   => p_caller,
                                   StatusCode => 11276,
                                   RunId      => GLOBAL_RUN_ID);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE FND_REPORT
(p_message_name IN VARCHAR2,
 p_token        IN VARCHAR2,
 p_value        IN VARCHAR2) IS
    l_message_text VARCHAR2(32000);
BEGIN
  IF p_token IS NULL THEN
     l_message_text := CZ_UTILS.GET_TEXT(p_message_name);
  ELSE
     l_message_text := CZ_UTILS.GET_TEXT(p_message_name,p_token,p_value);
  END IF;
  LOG_REPORT('CZ_RULES_SEQ',l_message_text);
END FND_REPORT;

PROCEDURE FND_REPORT
(p_message_name  IN VARCHAR2,
 p_token1        IN VARCHAR2,
 p_value1        IN VARCHAR2,
 p_token2        IN VARCHAR2,
 p_value2        IN VARCHAR2) IS
    l_message_text VARCHAR2(32000);
BEGIN
  IF p_token1 IS NULL THEN
     l_message_text := CZ_UTILS.GET_TEXT(p_message_name);
  ELSIF p_token2 IS NULL THEN
     l_message_text := CZ_UTILS.GET_TEXT(p_message_name,p_token1,p_value1);
  ELSE
     l_message_text := CZ_UTILS.GET_TEXT(p_message_name,p_token1,p_value1,p_token2,p_value2);
  END IF;
  LOG_REPORT('CZ_RULES_SEQ',l_message_text);
END FND_REPORT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Initialize(x_err OUT NOCOPY NUMBER) IS
BEGIN
  x_err:=0;
  SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;
END Initialize;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_Dates
(p_eff_set_id     IN  INTEGER,
 p_out_from_date  OUT NOCOPY DATE,
 p_out_until_date OUT NOCOPY DATE) IS

BEGIN
SELECT effective_from,effective_until INTO p_out_from_date,p_out_until_date
FROM CZ_EFFECTIVITY_SETS WHERE effectivity_set_id=p_eff_set_id;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
END;

PROCEDURE set_Dates
(p_rule_id        IN  INTEGER,
 p_from_date      IN  DATE,
 p_until_date     IN  DATE,
 p_eff_set_id     IN  INTEGER DEFAULT NULL,
 p_seq_nbr        IN  INTEGER DEFAULT NULL) IS

BEGIN

  UPDATE CZ_RULES
     SET effective_from=NVL(p_from_date,effective_from),
         effective_until=NVL(p_until_date,effective_until),
         effectivity_set_id=DECODE(p_eff_set_id,NULL_VALUE,NULL,NULL,effectivity_set_id,p_eff_set_id),
         seq_nbr=NVL(p_seq_nbr,seq_nbr)
  WHERE rule_id=p_rule_id AND deleted_flag=NO_FLAG;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_LCR
(p_model_id           IN  INTEGER,
 p_rule_sequence_id   IN  INTEGER,
 p_rule_id            IN  INTEGER,
 p_out_left_rule_id   OUT NOCOPY INTEGER,
 p_out_right_rule_id  OUT NOCOPY INTEGER,
 p_seq                IN OUT NOCOPY INTEGER,
 p_out_left_seq       OUT NOCOPY INTEGER,
 p_out_right_seq      OUT NOCOPY INTEGER,
 p_out_eff_from       OUT NOCOPY DATE,
 p_out_eff_to         OUT NOCOPY DATE,
 p_out_left_eff_from  OUT NOCOPY DATE,
 p_out_left_eff_to    OUT NOCOPY DATE,
 p_out_right_eff_from OUT NOCOPY DATE,
 p_out_right_eff_to   OUT NOCOPY DATE,
 p_out_left_set_id    OUT NOCOPY INTEGER,
 p_out_right_set_id   OUT NOCOPY INTEGER,
 p_out_set_id         OUT NOCOPY INTEGER) IS

var_curr_rule_id  INTEGER;
var_curr_nbr_seq  INTEGER;
var_set_id        INTEGER;
var_eff_from      DATE;
var_eff_to        DATE;

BEGIN

IF p_seq IS NULL THEN
   SELECT seq_nbr INTO p_seq FROM CZ_RULES
   WHERE rule_id=p_rule_id;
END IF;

p_out_left_seq:=NULL_VALUE;
p_out_right_seq:=NULL_VALUE;
p_out_left_set_id:=NULL_VALUE;
p_out_right_set_id:=NULL_VALUE;
p_out_set_id:=NULL_VALUE;
p_out_left_rule_id:=NULL_VALUE;
p_out_right_rule_id:=NULL_VALUE;
p_out_eff_from:=NULL;
p_out_eff_to:=NULL;
p_out_left_eff_from:=NULL;
p_out_left_eff_to:=NULL;
p_out_right_eff_from:=NULL;
p_out_right_eff_to:=NULL;


FOR i IN(SELECT a.rule_folder_id,a.rule_id,a.seq_nbr,p_seq as main_seq,
                DECODE(a.seq_nbr,p_seq,'C',p_seq-1,'L',p_seq+1,'R','N') as where_in_seq,
                NVL(a.effectivity_set_id,NULL_VALUE) as effectivity_set_id,
                DECODE(a.effectivity_set_id,NULL,a.effective_from,NULL_VALUE,a.effective_from,b.effective_from) as effective_from,
                DECODE(a.effectivity_set_id,NULL,a.effective_until,NULL_VALUE,a.effective_until,b.effective_until) as effective_until
         FROM CZ_RULES a,CZ_EFFECTIVITY_SETS b
         WHERE a.rule_folder_id=p_rule_sequence_id
         AND a.seq_nbr BETWEEN (p_seq-1) AND (p_seq+1)
         AND a.deleted_flag='0'
         AND b.effectivity_set_id(+)=a.effectivity_set_id
         AND b.deleted_flag(+)='0')
LOOP

    IF i.where_in_seq='C' THEN
       p_out_eff_from:=i.effective_from;
       p_out_eff_to:=i.effective_until;
       p_out_set_id:=i.effectivity_set_id;
    END IF;

    IF i.where_in_seq='L' THEN
       p_out_left_seq:=i.seq_nbr;
       p_out_left_rule_id:=i.rule_id;
       p_out_left_eff_from:=i.effective_from;
       p_out_left_eff_to:=i.effective_until;
       p_out_left_set_id:=i.effectivity_set_id;
    END IF;

    IF i.where_in_seq='R' THEN
       p_out_right_seq:=i.seq_nbr;
       p_out_right_rule_id:=i.rule_id;
       p_out_right_eff_from:=i.effective_from;
       p_out_right_eff_to:=i.effective_until;
       p_out_right_set_id:=i.effectivity_set_id;
    END IF;

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_NEWLCR
(p_model_id           IN  INTEGER,
 p_rule_sequence_id   IN  INTEGER,
 p_seq_nbr            IN  INTEGER,
 p_out_left_rule_id   OUT NOCOPY INTEGER,
 p_out_left_eff_from  OUT NOCOPY DATE,
 p_out_left_eff_to    OUT NOCOPY DATE,
 p_out_left_set_id    OUT NOCOPY INTEGER,
 p_out_right_rule_id  OUT NOCOPY INTEGER,
 p_out_right_eff_from OUT NOCOPY DATE,
 p_out_right_eff_to   OUT NOCOPY DATE,
 p_out_right_set_id   OUT NOCOPY INTEGER) IS

var_curr_rule_id  INTEGER;
var_curr_nbr_seq  INTEGER;
var_set_id        INTEGER;
var_eff_from      DATE;
var_eff_to        DATE;

BEGIN

p_out_left_rule_id:=NULL;
p_out_left_eff_from:=NULL;
p_out_left_eff_to:=NULL;
p_out_left_set_id:=NULL;

p_out_right_rule_id:=NULL;
p_out_right_eff_from:=NULL;
p_out_right_eff_to:=NULL;
p_out_right_set_id:=NULL;

BEGIN
SELECT effective_from,effective_until,effectivity_set_id,rule_id INTO
       p_out_left_eff_from,p_out_left_eff_to,p_out_left_set_id,p_out_left_rule_id
FROM CZ_RULES WHERE devl_project_id=p_model_id AND rule_folder_id=p_rule_sequence_id
AND seq_nbr=p_seq_nbr;

IF p_out_left_set_id IS NOT NULL THEN
   SELECT effective_from,effective_until INTO
          p_out_left_eff_from,p_out_left_eff_to
   FROM CZ_EFFECTIVITY_SETS WHERE effectivity_set_id=p_out_left_set_id;
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     /* *** Left Border case *** */
    NULL;
END;

BEGIN
SELECT effective_from,effective_until,effectivity_set_id,rule_id INTO
       p_out_right_eff_from,p_out_right_eff_to,p_out_right_set_id,p_out_right_rule_id
FROM CZ_RULES WHERE devl_project_id=p_model_id AND rule_folder_id=p_rule_sequence_id
AND seq_nbr=p_seq_nbr+1;

IF p_out_right_set_id IS NOT NULL THEN
   SELECT effective_from,effective_until INTO
          p_out_right_eff_from,p_out_right_eff_to
   FROM CZ_EFFECTIVITY_SETS WHERE effectivity_set_id=p_out_right_set_id;
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     /* *** Right Border case *** */
    NULL;
END;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE 	RemoveFromSequence
(p_rule_sequence_id 	IN    INTEGER,	              --ID of the rule sequence
p_model_id		      IN    INTEGER,	              --ID of the model
p_rule_id               IN    INTEGER,	              --ID of the rule which was removed
p_out_err               OUT NOCOPY   INTEGER ,	              --err flag
deleted_flag		IN    VARCHAR2 -- DEFAULT '0'      -- flag if the rule was logically deleted
) IS
var_curr_rule_id   INTEGER;
var_curr_seq       INTEGER;
var_left_seq       INTEGER;
var_right_seq      INTEGER;
var_next_rule_id   INTEGER;
var_prev_rule_id   INTEGER;
var_left_rule_id   INTEGER;
var_right_rule_id  INTEGER;
var_left_set_id    INTEGER;
var_right_set_id   INTEGER;
var_set_id         INTEGER;
var_eff_from       DATE;
var_eff_to         DATE;
var_left_eff_from  DATE;
var_left_eff_to    DATE;
var_right_eff_from DATE;
var_right_eff_to   DATE;

DO_NOTHING         EXCEPTION;

BEGIN

p_out_err:=0;

SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;

get_LCR
(p_model_id,p_rule_sequence_id,p_rule_id,
 var_left_rule_id,var_right_rule_id,
 var_curr_seq,var_left_seq,var_right_seq,
 var_eff_from,var_eff_to,
 var_left_eff_from,var_left_eff_to,
 var_right_eff_from,var_right_eff_to,
 var_left_set_id,var_right_set_id,var_set_id);

BEGIN

IF (var_eff_from=EPOCH_END AND var_eff_to=EPOCH_BEGIN) OR
    var_left_rule_id IS NULL THEN
    RAISE DO_NOTHING;
END IF;

/* *** handle the case with fisrt rule separately *** */
IF var_curr_seq=1 THEN
   set_Dates(var_right_rule_id,var_eff_from,var_right_eff_to,NULL_VALUE);
ELSE
   set_Dates(var_left_rule_id,var_left_eff_from,var_eff_to,NULL_VALUE);
END IF;

EXCEPTION
WHEN DO_NOTHING THEN
     NULL;
END;

/* *** shift all successors to the left side *** */

UPDATE CZ_RULES
SET seq_nbr=seq_nbr-1
WHERE  devl_project_id=p_model_id AND seq_nbr>var_curr_seq AND
rule_folder_id=p_rule_sequence_id AND deleted_flag=NO_FLAG;


/* *** delete current rule from sequence *** */

UPDATE CZ_RULES
SET seq_nbr=NULL_VALUE,
    rule_folder_id=NULL_VALUE
WHERE  rule_id=p_rule_id AND deleted_flag=NO_FLAG;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    p_out_err:=GLOBAL_RUN_ID;
    LOG_REPORT('CZ_RULES_SEQ.RemoveFromSequence','rule_id='||TO_CHAR(p_rule_id)||' : '||SQLERRM);
WHEN OTHERS THEN
    p_out_err:=GLOBAL_RUN_ID;
    LOG_REPORT('CZ_RULES_SEQ.RemoveFromSequence','rule_id='||TO_CHAR(p_rule_id)||' : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE 	MoveInSequence
(p_rule_sequence_id IN	INTEGER,	              -- ID of the rule sequence
p_model_id		      IN	INTEGER,	              -- ID of the model
p_rule_id	      	  IN	INTEGER,	              -- ID of the rule which is moved within the sequence
p_new_sequence		  IN	INTEGER,	              -- New sequence number of the moved rule
p_out_err           OUT NOCOPY INTEGER	        -- err flag
) IS

  var_curr_seq           INTEGER;
  var_left_seq           INTEGER;
  var_right_seq          INTEGER;
  var_left_rule_id       INTEGER;
  var_right_rule_id      INTEGER;
  var_left_set_id        INTEGER;
  var_right_set_id       INTEGER;
  var_set_id             INTEGER;
  var_eff_from           DATE;
  var_eff_to             DATE;
  var_left_eff_from      DATE;
  var_left_eff_to        DATE;
  var_right_eff_from     DATE;
  var_right_eff_to       DATE;
  var_target_left_rule_id    NUMBER;
  var_target_left_eff_from   DATE;
  var_target_left_eff_to     DATE;
  var_target_left_set_id     NUMBER;
  var_target_right_rule_id   NUMBER;
  var_target_right_eff_from  DATE;
  var_target_right_eff_to    DATE;
  var_target_right_set_id    NUMBER;

BEGIN

  Initialize(p_out_err);

  get_LCR
   (p_model_id,p_rule_sequence_id,p_rule_id,
    var_left_rule_id,var_right_rule_id,
    var_curr_seq,var_left_seq,var_right_seq,
    var_eff_from,var_eff_to,
    var_left_eff_from,var_left_eff_to,
    var_right_eff_from,var_right_eff_to,
    var_left_set_id,var_right_set_id,var_set_id);

  /** assume that we are moving Rn to the place of Rm
   *  ... Rn-1 Rn Rn+1 ... Rm-1 Rm Rm+1
   *
   *
   */
  IF p_new_sequence > var_curr_seq THEN
    --
    -- Rn-1 does not exist
    --
    IF var_left_rule_id=NULL_VALUE THEN
       IF var_eff_from < var_eff_to THEN
         IF var_eff_to=EPOCH_END AND var_right_eff_to=EPOCH_BEGIN THEN
           set_Dates(var_right_rule_id,var_eff_from,var_eff_to,NULL_VALUE);
         ELSE
           IF var_right_eff_to=EPOCH_BEGIN THEN
             set_Dates(var_right_rule_id,var_eff_from,var_eff_to,NULL_VALUE);
           ELSE
             set_Dates(var_right_rule_id,var_eff_from,var_right_eff_to,NULL_VALUE);
           END IF;
         END IF;
       ELSE
         --
         -- if var_eff_from=var_eff_to ( and => = var_right_eff_from )
         -- then we don't need to set dates for the right rule
         --
         NULL;
       END IF;

    ELSE -- Rn-1 exists

       IF var_eff_from < var_eff_to THEN
         set_Dates(var_left_rule_id,var_left_eff_from,var_eff_to,NULL_VALUE);
       ELSE
         --
         -- if var_eff_from=var_eff_to ( and => = var_right_eff_from )
         -- then we don't need to set dates for the right rule
         --
         NULL;
       END IF;

    END IF; -- end of IF var_left_rule_id=NULL_VALUE THEN

    --
    -- get dates of Rm-1, Rm and Rm+1
    --
    get_NEWLCR(p_model_id,p_rule_sequence_id,p_new_sequence,
               var_target_left_rule_id,var_target_left_eff_from,var_target_left_eff_to,
               var_target_left_set_id,var_target_right_rule_id,var_target_right_eff_from,
               var_target_right_eff_to,var_target_right_set_id);

    IF var_target_left_eff_to IN(EPOCH_END,EPOCH_BEGIN) THEN
      IF var_eff_from=EPOCH_END AND var_eff_to=EPOCH_BEGIN THEN
        set_Dates(p_rule_id,EPOCH_END,EPOCH_BEGIN,NULL_VALUE);
      ELSE
        set_Dates(p_rule_id,EPOCH_END,EPOCH_BEGIN,NULL);
      END IF;
    ELSE
      set_Dates(p_rule_id,var_target_left_eff_to,var_target_left_eff_to,NULL_VALUE);
    END IF;

    UPDATE CZ_RULES
       SET seq_nbr=seq_nbr-1
     WHERE rule_folder_id=p_rule_sequence_id AND
           seq_nbr > var_curr_seq AND
           seq_nbr <= p_new_sequence AND
           deleted_flag=NO_FLAG;

    UPDATE CZ_RULES
       SET seq_nbr=p_new_sequence
     WHERE rule_id=p_rule_id;

  END IF;

  /** assume that we are moving Rn to the place of Rm
   *  ... Rm-1 Rm Rm+1 ... Rn-1 Rn Rn+1
   *
   *
   */
  IF p_new_sequence < var_curr_seq THEN
    --
    -- Rn+1 does not exist
    --
    IF var_right_rule_id=NULL_VALUE OR var_right_eff_from=EPOCH_END THEN
       IF var_eff_from < var_eff_to THEN
         set_Dates(var_left_rule_id,var_left_eff_from,var_eff_to,NULL_VALUE);
       ELSE
         --
         -- if var_eff_from=var_eff_to ( and => = var_right_eff_from )
         -- then we don't need to set dates for the right rule
         --
         NULL;
       END IF;

    ELSE -- Rn+1 exists

       IF var_eff_from < var_eff_to THEN
         set_Dates(var_right_rule_id,var_eff_from,var_right_eff_to,NULL_VALUE);
       ELSE
         --
         -- if var_eff_from=var_eff_to ( and => = var_right_eff_from )
         -- then we don't need to set dates for the right rule
         --
         NULL;
       END IF;

    END IF; -- end of IF var_left_rule_id=NULL_VALUE THEN

    --
    -- get dates of Rm-1, Rm and Rm+1
    --
    get_NEWLCR(p_model_id,p_rule_sequence_id,p_new_sequence,
               var_target_left_rule_id,var_target_left_eff_from,var_target_left_eff_to,
               var_target_left_set_id,var_target_right_rule_id,var_target_right_eff_from,
               var_target_right_eff_to,var_target_right_set_id);

    IF var_target_left_eff_to IN(EPOCH_END,EPOCH_BEGIN) THEN
      IF var_eff_from=EPOCH_END AND var_eff_to=EPOCH_BEGIN THEN
        IF var_target_left_eff_from IN(EPOCH_END) THEN
          set_Dates(p_rule_id,EPOCH_END,EPOCH_BEGIN,NULL_VALUE);
        ELSIF var_target_left_eff_from IN(EPOCH_BEGIN) AND var_target_left_eff_to=EPOCH_END THEN
          set_Dates(p_rule_id,EPOCH_BEGIN,EPOCH_END,NULL);
        ELSE
          set_Dates(p_rule_id,var_target_left_eff_from,var_target_left_eff_from,NULL);
        END IF;

      ELSE
        IF var_target_left_eff_from IN(EPOCH_END) THEN
           set_Dates(p_rule_id,EPOCH_END,EPOCH_BEGIN,NULL);
        ELSIF var_target_left_eff_from IN(EPOCH_BEGIN) AND var_target_left_eff_to=EPOCH_END THEN
          set_Dates(p_rule_id,EPOCH_BEGIN,EPOCH_END,NULL);
        ELSE
          set_Dates(p_rule_id,var_target_left_eff_from,var_target_left_eff_from,NULL);
        END IF;

      END IF;
    ELSE
      IF var_target_left_eff_from=EPOCH_BEGIN THEN
        set_Dates(p_rule_id,var_target_left_eff_from,var_target_left_eff_to,NULL_VALUE);
        set_Dates(var_target_left_rule_id,var_target_left_eff_to,var_target_left_eff_to,NULL_VALUE);
      ELSE
        set_Dates(p_rule_id,var_target_left_eff_from,var_target_left_eff_from,NULL_VALUE);
      END IF;
    END IF;

    UPDATE CZ_RULES
       SET seq_nbr=seq_nbr+1
     WHERE rule_folder_id=p_rule_sequence_id AND
           seq_nbr < var_curr_seq AND
           seq_nbr >= p_new_sequence AND
           deleted_flag=NO_FLAG;

    UPDATE CZ_RULES
       SET seq_nbr=p_new_sequence
     WHERE rule_id=p_rule_id;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      p_out_err:=GLOBAL_RUN_ID;
      LOG_REPORT('CZ_RULES_SEQ.MoveInSequence','rule_id='||TO_CHAR(p_rule_id)||' : '||SQLERRM);
  WHEN OTHERS THEN
      p_out_err:=GLOBAL_RUN_ID;
      LOG_REPORT('CZ_RULES_SEQ.MoveInSequence','rule_id='||TO_CHAR(p_rule_id)||' : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE 	ChangeEffectivity
(p_rule_sequence_id 	IN	INTEGER,	              --ID of the rule sequence
 p_model_id	      	IN	INTEGER,	              --ID of the model
 p_rule_id	      	IN	INTEGER,	              --ID of the rule whose effectivity changed
 p_out_err	       	  OUT NOCOPY INTEGER,	              --err flag
 p_eff_start_date		IN	DATE DEFAULT NULL,	  --New start date
 p_eff_end_date		IN	DATE DEFAULT NULL,	  --New end date
 p_eff_set_id		IN	INTEGER -- DEFAULT -1        --New effectivity set ID
) IS

var_curr_rule_id   INTEGER;
var_curr_seq       INTEGER;
var_new_curr_seq   INTEGER;
var_left_seq       INTEGER;
var_right_seq      INTEGER;
var_next_rule_id   INTEGER;
var_prev_rule_id   INTEGER;
var_left_rule_id   INTEGER;
var_right_rule_id  INTEGER;
var_new_rule_id    INTEGER;
var_left_set_id    INTEGER;
var_right_set_id   INTEGER;
var_set_id         INTEGER;
var_from_date      DATE;
var_until_date     DATE;
var_eff_from       DATE;
var_eff_to         DATE;
var_left_eff_from  DATE;
var_left_eff_to    DATE;
var_right_eff_from DATE;
var_right_eff_to   DATE;

END_OPERATION      EXCEPTION;

BEGIN

p_out_err:=0;

SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;

get_LCR
(p_model_id,p_rule_sequence_id,p_rule_id,
 var_left_rule_id,var_right_rule_id,
 var_curr_seq,var_left_seq,var_right_seq,
 var_eff_from,var_eff_to,
 var_left_eff_from,var_left_eff_to,
 var_right_eff_from,var_right_eff_to,
 var_left_set_id,var_right_set_id,var_set_id);

IF p_eff_start_date=EPOCH_END AND p_eff_end_date=EPOCH_BEGIN THEN

   IF (var_left_eff_from=EPOCH_END AND var_left_eff_to=EPOCH_BEGIN)
      OR var_left_eff_to=EPOCH_END THEN
      set_Dates(p_rule_id,NULL,NULL,p_eff_set_id);
      RAISE END_OPERATION;
   END IF;

   IF var_eff_from=EPOCH_END AND var_eff_to=EPOCH_BEGIN THEN
      set_Dates(p_rule_id,NULL,NULL,p_eff_set_id);
      RAISE END_OPERATION;
   END IF;

   set_Dates(var_left_rule_id,var_left_eff_from,var_eff_to,NULL_VALUE);
   set_Dates(p_rule_id,EPOCH_END,EPOCH_BEGIN,p_eff_set_id);
   RAISE END_OPERATION;

END IF;

IF var_left_rule_id IS NULL THEN
   IF p_eff_end_date=var_right_eff_from THEN
      NULL;
   ELSE
      set_Dates(var_right_rule_id,p_eff_end_date,var_right_eff_to,NULL_VALUE);
   END IF;
   set_Dates(p_rule_id,p_eff_start_date,p_eff_end_date,p_eff_set_id);
   RAISE END_OPERATION;
END IF;

IF var_right_rule_id IS NULL THEN
   IF p_eff_start_date=var_left_eff_to THEN
      NULL;
   ELSE
      set_Dates(var_left_rule_id,var_left_eff_from,p_eff_start_date,NULL_VALUE);
   END IF;
   set_Dates(p_rule_id,p_eff_start_date,p_eff_end_date,p_eff_set_id);
   RAISE END_OPERATION;
END IF;

IF var_eff_from=EPOCH_END AND var_eff_to=EPOCH_BEGIN THEN
   IF p_eff_start_date=var_left_eff_to THEN
      set_Dates(var_left_rule_id,var_left_eff_from,p_eff_start_date);
   ELSE
      set_Dates(var_left_rule_id,var_left_eff_from,p_eff_start_date,NULL_VALUE);
   END IF;
   set_Dates(p_rule_id,p_eff_start_date,p_eff_end_date,p_eff_set_id);
   RAISE END_OPERATION;
END IF;

IF p_eff_start_date=var_left_eff_to THEN
   set_Dates(var_left_rule_id,var_left_eff_from,p_eff_start_date);
ELSE
   set_Dates(var_left_rule_id,var_left_eff_from,p_eff_start_date,NULL_VALUE);
END IF;

IF var_right_eff_from=EPOCH_END AND var_right_eff_to=EPOCH_BEGIN THEN
   NULL;
ELSE
   IF p_eff_end_date=var_right_eff_from THEN
      set_Dates(var_right_rule_id,p_eff_end_date,var_right_eff_to);
   ELSE
      set_Dates(var_right_rule_id,p_eff_end_date,var_right_eff_to,NULL_VALUE);
   END IF;
END IF;

set_Dates(p_rule_id,p_eff_start_date,p_eff_end_date,p_eff_set_id);

EXCEPTION
WHEN END_OPERATION THEN
     NULL;
WHEN NO_DATA_FOUND THEN
    p_out_err:=1;
    LOG_REPORT('CZ_RULES_SEQ.ChangeEffectivity','rule_id='||TO_CHAR(p_rule_id)||' : '||SQLERRM);
WHEN OTHERS THEN
    p_out_err:=2;
    LOG_REPORT('CZ_RULES_SEQ.ChangeEffectivity','rule_id='||TO_CHAR(p_rule_id)||' : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE 	PropagateEffectivitySetChange
(p_effectivity_set_id   IN 	INTEGER,                  --ID of the effectivity set
 p_new_start_date       IN	DATE,                     --new start date
 p_new_end_date         IN	DATE,		              --new end date
 p_out_err                OUT NOCOPY INTEGER                   --Err flag
) IS

var_start_date     DATE;
var_end_date       DATE;

var_curr_rule_id   INTEGER;
var_curr_seq       INTEGER;
var_left_seq       INTEGER;
var_right_seq      INTEGER;
var_next_rule_id   INTEGER;
var_prev_rule_id   INTEGER;
var_left_rule_id   INTEGER;
var_right_rule_id  INTEGER;
var_new_rule_id    INTEGER;
var_left_set_id    INTEGER;
var_right_set_id   INTEGER;
var_set_id         INTEGER;
var_name           CZ_RULES.name%TYPE;
var_eff_name       CZ_EFFECTIVITY_SETS.name%TYPE;
var_rule_name      CZ_RULES.name%TYPE;

var_eff_from       DATE;
var_eff_to         DATE;
var_left_eff_from  DATE;
var_left_eff_to    DATE;
var_right_eff_from DATE;
var_right_eff_to   DATE;

LEFT_OVERLAP       EXCEPTION;
RIGHT_OVERLAP      EXCEPTION;

BEGIN

FND_MSG_PUB.initialize;
p_out_err:=0;

SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;

UPDATE CZ_EFFECTIVITY_SETS
SET effective_from=p_new_start_date,
    effective_until=p_new_end_date
WHERE effectivity_set_id=p_effectivity_set_id RETURNING name INTO var_eff_name;

FOR k IN ( SELECT a.* FROM CZ_RULES a, CZ_RULE_FOLDERS b
           WHERE a.rule_folder_id = b.rule_folder_id
           AND b.folder_type=1 AND b.deleted_flag=NO_FLAG
           AND a.effectivity_set_id=p_effectivity_set_id
           AND a.deleted_flag=NO_FLAG)
LOOP

      var_curr_seq:=k.seq_nbr;

      get_LCR
      (k.devl_project_id,k.rule_folder_id,k.rule_id,
       var_left_rule_id,var_right_rule_id,
       var_curr_seq,var_left_seq,var_right_seq,
       var_eff_from,var_eff_to,var_left_eff_from,var_left_eff_to,
       var_right_eff_from,var_right_eff_to,
       var_left_set_id,var_right_set_id,var_set_id);

      IF p_new_start_date<var_left_eff_from THEN
         var_rule_name:=k.name;
         RAISE LEFT_OVERLAP;
      END IF;

      IF p_new_end_date>var_right_eff_to
         AND var_right_eff_to<>CZ_UTILS.EPOCH_BEGIN_ THEN
         RAISE RIGHT_OVERLAP;
      END IF;

      IF (var_left_set_id<>NULL_VALUE AND var_left_set_id IS NOT NULL) AND
         (var_left_eff_from=CZ_UTILS.EPOCH_END_ AND var_left_eff_to=CZ_UTILS.EPOCH_BEGIN_) THEN

          NULL;
      ELSE
          set_Dates(var_left_rule_id,var_left_eff_from,p_new_start_date,NULL_VALUE);
      END IF;


      IF (var_right_set_id<>NULL_VALUE  AND var_right_set_id IS NOT NULL) AND
         (var_right_eff_from=CZ_UTILS.EPOCH_END_ AND var_right_eff_to=CZ_UTILS.EPOCH_BEGIN_)  THEN
          NULL;
      ELSE
          set_Dates(var_right_rule_id,p_new_end_date,var_right_eff_to,NULL_VALUE);
      END IF;

END LOOP;

EXCEPTION
WHEN LEFT_OVERLAP THEN
    p_out_err:=GLOBAL_RUN_ID;
    SELECT name INTO var_name FROM CZ_RULES WHERE rule_id=var_left_rule_id;
    IF var_left_eff_from=EPOCH_END AND var_left_eff_to=EPOCH_BEGIN THEN
       FND_REPORT('CZ_UNABLE_TO_ACTIVATE_RULE','RULENAME',var_name);
    ELSE
       FND_REPORT('CZ_EFF_SET_PREV_OVERLAP','EFFNAME',var_eff_name,'RULENAME',var_name);
    END IF;
WHEN RIGHT_OVERLAP THEN
    p_out_err:=GLOBAL_RUN_ID;
    SELECT name INTO var_name FROM CZ_RULES WHERE rule_id=var_right_rule_id;
    FND_REPORT('CZ_EFF_SET_NEXT_OVERLAP','EFFNAME',var_eff_name,'RULENAME',var_name);
WHEN NO_DATA_FOUND THEN
    p_out_err:=GLOBAL_RUN_ID;
    SELECT name INTO var_name FROM CZ_RULES WHERE rule_id=var_right_rule_id;
    LOG_REPORT('CZ_RULES_SEQ','effectivity "'||var_eff_name||'" : '||SQLERRM);
WHEN OTHERS THEN
    p_out_err:=GLOBAL_RUN_ID;
    LOG_REPORT('CZ_RULES_SEQ','effectivity "'||var_eff_name||'" : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

END;

/
