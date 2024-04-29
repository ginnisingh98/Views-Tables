--------------------------------------------------------
--  DDL for Package MSC_ASK_ORACLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ASK_ORACLE" AUTHID CURRENT_USER AS
/*$Header: MSCASKOS.pls 120.2 2005/07/06 13:21:56 pabram noship $ */

PROCEDURE register_question(
   errbuf             OUT NoCopy VARCHAR2,
   retcode            OUT NoCopy VARCHAR2,
   x_mode             IN  NUMBER,
   x_question_code    IN  VARCHAR2,
   x_question_type    IN  VARCHAR2 DEFAULT NULL,
   x_lang_code        IN  VARCHAR2 DEFAULT NULL,
   x_question         IN  VARCHAR2 DEFAULT NULL,
   x_package_name     IN  VARCHAR2 DEFAULT NULL,
   x_copy_question    IN  VARCHAR2 DEFAULT NULL);

FUNCTION ask(
   x_question_id      IN  NUMBER,
   x_question_type    IN  VARCHAR2,
   x_question         IN  VARCHAR2,
   x_plan_id          IN  NUMBER,
   x_key1             IN  NUMBER DEFAULT NULL,
   x_key2             IN  NUMBER DEFAULT NULL,
   x_key3             IN  NUMBER DEFAULT NULL,
   x_key4             IN  NUMBER DEFAULT NULL,
   x_answer_id        OUT NoCopy NUMBER,
   x_err_msg          OUT NoCopy VARCHAR2,
   x_msg_count        OUT NoCopy NUMBER)
RETURN BOOLEAN;

PROCEDURE get_question(
   x_question_id      OUT NoCopy NUMBER,
   x_question_type    OUT NoCopy VARCHAR2,
   x_question_code    OUT NoCopy NUMBER);

PROCEDURE get_key(
   x_question_type    OUT NoCopy VARCHAR2,
   x_plan_id          OUT NoCopy NUMBER,
   x_key1             OUT NoCopy NUMBER,
   x_key2             OUT NoCopy NUMBER);

PROCEDURE get_answer_id(
    answer_id OUT NoCopy NUMBER);

PROCEDURE insert_answer(
    a_id IN NUMBER,
    q_id IN NUMBER,
    seq  IN NUMBER,
    ans  IN VARCHAR2);

PROCEDURE late_prj(
   x_answer_id        IN OUT NoCopy NUMBER,
   x_err_msg          IN OUT NoCopy VARCHAR2,
   x_msg_count        IN OUT NoCopy NUMBER);

PROCEDURE late_supply(
   x_answer_id        IN OUT NoCopy NUMBER,
   x_err_msg          IN OUT NoCopy VARCHAR2,
   x_msg_count        IN OUT NoCopy NUMBER);

PROCEDURE late_demand(
   x_answer_id        IN OUT NoCopy NUMBER,
   x_err_msg          IN OUT NoCopy VARCHAR2,
   x_msg_count        IN OUT NoCopy NUMBER);

v_question_id   NUMBER   := NULL;
v_question_code VARCHAR2(25) := NULL;
v_question      VARCHAR2(240) := NULL;
v_question_type VARCHAR2(10) := NULL;
v_plan_id       NUMBER   := NULL;
v_key1          NUMBER   := NULL;
v_key2          NUMBER   := NULL;
v_seq_num       NUMBER   := 0;

END msc_ask_oracle;

 

/
