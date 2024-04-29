--------------------------------------------------------
--  DDL for Package FND_WEB_RESOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WEB_RESOURCE_PKG" AUTHID CURRENT_USER AS
 /* $Header: AFSCWRSS.pls 120.0.12010000.3 2019/11/15 06:13:57 ssumaith noship $ */

  PROCEDURE load_web_resource(
	P_RESOURCE_NAME in VARCHAR2,
	P_APPLICATION_SHORT_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2
	);

  FUNCTION web_resource_exists(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2
	) RETURN boolean;

  procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure LOCK_ROW (
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2
);

procedure UPDATE_ROW (
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2
);

procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_RESOURCE_NAME in VARCHAR2,
  X_RESOURCE_TYPE in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
 );

procedure AUDIT_RESOURCE(
	P_RESOURCE_NAME in VARCHAR2,
	P_LAST_ACCESSED_BY in NUMBER default null,
	P_LAST_ACCESSED_DATE in VARCHAR2 default null,
	P_FIRST_ACCESSED_BY in NUMBER default null,
	P_FIRST_ACCESSED_DATE in VARCHAR2 default null,
	P_ACCESS_COUNT in VARCHAR2 default null,
	P_IS_ACCEPTED in VARCHAR2 default null
	);

procedure ALLOW_DENY_RESOURCE (
   X_RESOURCE_NAME in VARCHAR2,
   X_RESOURCE_TYPE in VARCHAR2,
   X_RESOURCE_STATE in VARCHAR2
);

function IS_RESOURCE_ALLOWED(
		P_RESOURCE_NAME in VARCHAR2,
		P_RESOURCE_TYPE in VARCHAR2
		) return VARCHAR2;

 function IS_SUFFICIENT_WEB_ACTIVITY
 return BOOLEAN;

 function GET_WEB_ACTIVITY_STATUS(
	P_RESOURCE_NAME in VARCHAR2 default null,
	P_APP_SHORT_NAME in VARCHAR2 default null
	) return VARCHAR2;

 function GET_USED_COUNT(
	P_RESOURCE_NAME in VARCHAR2,
	P_RESOURCE_TYPE in VARCHAR2
	) return NUMBER;

	/* Cache invalidation.

THe UI must notify the cache that a change had been made and metadata must be reloaded.

See Bug 25599446
*/
  procedure InvalidateCache;

  /* added by ssumaith */
  procedure ALLOW_DENY_RESOURCES(p_res_attrs            IN FND_WEB_RESOURCE_TBL,
		                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_num_records          OUT NOCOPY NUMBER);

 END fnd_web_resource_pkg;

/
