--------------------------------------------------------
--  DDL for Package Body PER_PERSON_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERSON_PROFILE" AS
/* $Header: peppgpbe.pkb 120.0.12010000.3 2008/11/26 12:53:20 srgnanas noship $ */

PROCEDURE raise_event(p_event       IN wf_event_t)
IS
    l_event_key         NUMBER;
    l_event_data        CLOB;
    l_event_name        VARCHAR2(250) := 'oracle.apps.per.person.profile';
    l_parameter_list    wf_parameter_list_t;
    l_text              VARCHAR2(2000);
    l_message           VARCHAR2(10);

    CURSOR get_seq IS
        SELECT per_wf_events_s.NEXTVAL FROM dual;

    l_doc            dbms_xmldom.domdocument := NULL;
    l_doce           dbms_xmldom.domelement := NULL;

    l_proc           VARCHAR2(72):='  per_person_profile.raise_event';
BEGIN
    hr_utility.set_location('Entering: '||l_proc,10);
    l_message:=wf_event.test(l_event_name);
    --
    l_event_data := p_event.getEventData();
    l_event_key  := p_event.getEventKey();

    wf_event.AddParameterToList(p_name          => 'EVENT_TYPE',
                                p_value         => p_event.getEventName(),
                                p_parameterlist => l_parameter_list);

    IF (l_message='MESSAGE') THEN
        hr_utility.set_location(l_proc,20);
        --
        -- get a key for the event
        --
        OPEN get_seq;
        FETCH get_seq INTO l_event_key;
        CLOSE get_seq;

       -- raise the event with the event data
       wf_event.raise(p_event_name  => l_event_name
                     ,p_event_key   => l_event_key
                     ,p_event_data  => l_event_data
                     ,p_parameters  => l_parameter_list);

    ELSIF (l_message='KEY') THEN
        hr_utility.set_location(l_proc,30);
        -- get a key for the event
        OPEN get_seq;
        FETCH get_seq INTO l_event_key;
        CLOSE get_seq;
       -- this is a key event, so just raise the event
       -- without the event data
       wf_event.raise(p_event_name  => l_event_name
                     ,p_event_key   => l_event_key
                     ,p_parameters  => l_parameter_list);

    ELSIF (l_message='NONE') THEN
        hr_utility.set_location(l_proc,40);
        -- no event is required, so do nothing
        NULL;
    END IF;
    hr_utility.set_location('Leaving: '||l_proc,50);
END raise_event;

FUNCTION raise_person_profile_event( p_subscription_guid IN RAW
                              ,p_event IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2
IS
    l_proc                  VARCHAR2(72):='  per_person_profile.raise_person_profile_event';
BEGIN
    hr_utility.set_location('Entering: '|| l_proc,10);

    raise_event(p_event       => p_event);

    hr_utility.set_location('Leaving: '||l_proc,50);
    RETURN 'SUCCESS';
    EXCEPTION
        WHEN OTHERS THEN
            hr_utility.trace('Error at per_person_profile.raise_person_profile_event - ' || SQLERRM );
            hr_utility.trace_off;
        RETURN 'ERROR';
END raise_person_profile_event;
END per_person_profile;

/
