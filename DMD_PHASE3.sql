CREATE SCHEMA "CarSharingComp";

CREATE TABLE "CarSharingComp".charging_station ( 
	uid                  uuid  NOT NULL,
	available_sockets    integer  NOT NULL,
	vehicle_id           uuid  ,
	capacity             integer  NOT NULL,
	latitude             real  NOT NULL,
	longitude           real  NOT NULL,
	CONSTRAINT pk_charging_station_uid PRIMARY KEY ( uid ),
	CONSTRAINT idx_charging_station_vehicle_id UNIQUE ( vehicle_id ) 
 );

CREATE TABLE "CarSharingComp".employee ( 
	uid                  uuid  NOT NULL,
	status               varchar(15)  NOT NULL,
	salary               integer  NOT NULL,
	firstname            varchar(100)  ,
	last_name            varchar(100)  NOT NULL,
	CONSTRAINT pk_employee_uid PRIMARY KEY ( uid )
 );

CREATE TABLE "CarSharingComp".garage ( 
	uid                  uuid  NOT NULL,
	capacity             integer  NOT NULL,
	available_places     integer  NOT NULL,
	latitude             real  NOT NULL,
	longitude           real  NOT NULL,
	CONSTRAINT pk_garage_uid PRIMARY KEY ( uid )
 );

CREATE TABLE "CarSharingComp".model ( 
	model                varchar  NOT NULL,
	company              varchar  NOT NULL,
	seats_number         smallint  NOT NULL,
	comfort_level        varchar(20)  NOT NULL,
	is_smoking_allowed   bool DEFAULT false NOT NULL,
	id                   uuid  NOT NULL,
	CONSTRAINT pk_model_id PRIMARY KEY ( id )
 );

CREATE INDEX idx_model_company ON "CarSharingComp".model ( company );

CREATE TABLE "CarSharingComp"."user" ( 
	uid                  uuid  NOT NULL,
	first_name           varchar(100)  NOT NULL,
	last_name            varchar(100)  NOT NULL,
	user_password        varchar(30)  NOT NULL,
	email                text  NOT NULL,
	rating               integer DEFAULT 10 NOT NULL,
	card_number          varchar  ,
	name_of_owner        varchar  ,
	cvv                  integer  ,
	date_of_out          varchar(5)  ,
	CONSTRAINT pk_user_uid PRIMARY KEY ( uid )
 );

CREATE TABLE "CarSharingComp".user_preferences ( 
	uid                  uuid  NOT NULL,
	preference           varchar(50)  ,
	CONSTRAINT fk_user_preferences_user FOREIGN KEY ( uid ) REFERENCES "CarSharingComp"."user"( uid )  
 );

CREATE INDEX idx_user_preferences_uid ON "CarSharingComp".user_preferences ( uid );

CREATE TABLE "CarSharingComp".vehicle ( 
	color                varchar(15)  NOT NULL,
	car_number           varchar(9)  NOT NULL,
	pets_allowing        bool DEFAULT false NOT NULL,
	ensurance_id         integer  NOT NULL,
	uid                  uuid  NOT NULL,
	charging_id          uuid  ,
	garage_id            uuid  ,
	model_id             uuid  NOT NULL,
	vehicle_year         integer  NOT NULL,
	CONSTRAINT pk_vehicle_uis PRIMARY KEY ( uid ),
	CONSTRAINT fk_vehicle_garage FOREIGN KEY ( garage_id ) REFERENCES "CarSharingComp".garage( uid )  ,
	CONSTRAINT fk_vehicle_model FOREIGN KEY ( model_id ) REFERENCES "CarSharingComp".model( id )  ,
	CONSTRAINT fk_vehicle_charging_station FOREIGN KEY ( charging_id ) REFERENCES "CarSharingComp".charging_station( uid )  
 );

CREATE INDEX idx_vehicle_charging_id ON "CarSharingComp".vehicle ( charging_id );

CREATE INDEX idx_vehicle_garage_id ON "CarSharingComp".vehicle ( garage_id );

CREATE INDEX unq_vehicle_model_id ON "CarSharingComp".vehicle ( model_id );

CREATE TABLE "CarSharingComp".administrator ( 
	username             varchar(100)  NOT NULL,
	"password"           varchar  NOT NULL,
	is_a_head_administrator bool  NOT NULL,
	employee_id          uuid  NOT NULL,
	CONSTRAINT unq_administrator_employee_id UNIQUE ( employee_id ) ,
	CONSTRAINT "is" FOREIGN KEY ( employee_id ) REFERENCES "CarSharingComp".employee( uid )
 );

CREATE TABLE "CarSharingComp".dinamic_data_vehicle ( 
	vehicle_id           uuid  NOT NULL,
	mileage              integer DEFAULT 0 NOT NULL,
	vehicle_state        varchar(15)  NOT NULL,
	charge_level         integer  NOT NULL,
	next_diagnoses_date   timestamptz  NOT NULL,
	latitude             real  NOT NULL,
	longitude           real  NOT NULL,
	CONSTRAINT pk_dinamic_data_vehicle_vehicle_id PRIMARY KEY ( vehicle_id ),
	CONSTRAINT fk_dinamic_data_vehicle_vehicle FOREIGN KEY ( vehicle_id ) REFERENCES "CarSharingComp".vehicle( uid )  
 );

CREATE TABLE "CarSharingComp".emergency_service_team ( 
	id                   uuid  NOT NULL,
	available            bool  NOT NULL,
	CONSTRAINT pk_emergency_service_team_id PRIMARY KEY ( id ),
	CONSTRAINT fk_emergency_service_team_vehicle FOREIGN KEY ( id ) REFERENCES "CarSharingComp".vehicle( uid )  
 );

CREATE TABLE "CarSharingComp".location_of_residence ( 
	uid                  uuid  NOT NULL,
	latitude             real  NOT NULL,
	longitude           real  NOT NULL,
	CONSTRAINT fk_location_of_residence_user FOREIGN KEY ( uid ) REFERENCES "CarSharingComp"."user"( uid )  
 );

CREATE INDEX idx_location_of_residence_uid ON "CarSharingComp".location_of_residence ( uid );

CREATE TABLE "CarSharingComp".mechanics ( 
	speciality           varchar(20)  ,
	employee_id          uuid  NOT NULL,
	works_in             uuid  ,
	in_team              uuid  ,
	CONSTRAINT "unq_mechanics_employee-id" UNIQUE ( employee_id ) ,
	CONSTRAINT fk_mechanics_garage FOREIGN KEY ( works_in ) REFERENCES "CarSharingComp".garage( uid )  ,
	CONSTRAINT fk_mechanics_employee FOREIGN KEY ( employee_id ) REFERENCES "CarSharingComp".employee( uid )  ,
	CONSTRAINT fk_mechanics_emergency_service_team FOREIGN KEY ( in_team ) REFERENCES "CarSharingComp".emergency_service_team( id )  
 );

CREATE INDEX idx_mechanics_works_in ON "CarSharingComp".mechanics ( works_in );

CREATE INDEX idx_mechanics_in_team ON "CarSharingComp".mechanics ( in_team );

CREATE TABLE "CarSharingComp"."order" ( 
	id                   uuid  NOT NULL,
	number_of_passengers smallint  NOT NULL,
	luggage              bool DEFAULT false ,
	is_smoking_allowed   bool DEFAULT false ,
	are_pets_allowed     bool DEFAULT false ,
	created_on           timestamptz  NOT NULL,
	number_of_children_under_12 smallint DEFAULT 0 ,
	feedback_of_ride     text  ,
	order_state          varchar(10)  NOT NULL,
	user_id              uuid  NOT NULL,
	vehicle_id           uuid  NOT NULL,
	distance             integer  NOT NULL,
	departure_time       timestamptz  NOT NULL,
	source_latitude     real  NOT NULL,
	source_longitude    real  NOT NULL,
	dest_latitude        real  NOT NULL,
	dest_longitude      real  NOT NULL,
	CONSTRAINT pk_order_id PRIMARY KEY ( id ),
	CONSTRAINT fk_order_user FOREIGN KEY ( user_id ) REFERENCES "CarSharingComp"."user"( uid )  ,
	CONSTRAINT fk_order_vehicle FOREIGN KEY ( vehicle_id ) REFERENCES "CarSharingComp".vehicle( uid )  
 );

CREATE INDEX idx_order_user_id ON "CarSharingComp"."order" ( user_id );

CREATE INDEX idx_order_vehicle_id ON "CarSharingComp"."order" ( vehicle_id );

CREATE TABLE "CarSharingComp".reports ( 
	uid                  uuid  NOT NULL,
	text                 text  ,
	team_id              uuid  ,
	CONSTRAINT pk_reports_uid PRIMARY KEY ( uid ),
	CONSTRAINT fk_reports_emergency_service_team FOREIGN KEY ( team_id ) REFERENCES "CarSharingComp".emergency_service_team( id )  
 );

CREATE INDEX idx_reports_team_id ON "CarSharingComp".reports ( team_id );

CREATE TABLE "CarSharingComp".request ( 
	uid                  uuid  NOT NULL,
	text                 text  ,
	user_id              uuid  NOT NULL,
	created_on            date  NOT NULL,
	admin_id             uuid  ,
	CONSTRAINT pk_request_uid PRIMARY KEY ( uid ),
	CONSTRAINT fk_request_administrator FOREIGN KEY ( admin_id ) REFERENCES "CarSharingComp".administrator( employee_id )  ,
	CONSTRAINT fk_request_user FOREIGN KEY ( user_id ) REFERENCES "CarSharingComp"."user"( uid )  
 );

CREATE INDEX idx_request_admin_id ON "CarSharingComp".request ( admin_id );

CREATE INDEX idx_request_user_id ON "CarSharingComp".request ( user_id );

CREATE TABLE "CarSharingComp".request_from_car ( 
	id                   uuid  NOT NULL,
	status               varchar(10)  NOT NULL,
	request_type         varchar(20)  NOT NULL,
	vehicle_id           uuid  NOT NULL,
	created_on           timestamptz  NOT NULL,
	latitude             real  NOT NULL,
	longitude           real  NOT NULL,
	CONSTRAINT pk_request_from_car_id PRIMARY KEY ( id ),
	CONSTRAINT fk_request_from_car_vehicle FOREIGN KEY ( vehicle_id ) REFERENCES "CarSharingComp".vehicle( uid )  
 );

CREATE INDEX idx_request_from_car_vehicle_id ON "CarSharingComp".request_from_car ( vehicle_id );

INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( 'cf07940b-5fbc-c6d4-4ee7-0a6725b37d1e', 4, 'c0a94378-d53d-669b-fe08-dd8b5e07a67d', 5, 14.72228, -20.74015 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( 'bfd8ccf3-3a57-a5d4-867f-5abba90d778a', 11, '7d3440ec-69fa-330e-fc12-29723137a991', 13, -36.02026, 28.5776 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '14f4433b-6eae-2e77-484f-a193d3db535b', 14, 'aa30ee09-005d-3e46-c257-2ec13e94923d', 12, 53.59899, 99.69847 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( 'c3dcda66-85d8-1565-2b4a-aa27433d9cba', 4, '1e985aef-8aac-a398-1657-96d1c5eeb962', 5, -19.0175, -47.57558 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '7b688d9c-d69f-1aff-ed5a-e315f06c8c20', 7, 'e1138034-04fd-11f8-b3ac-c02180ab0cf6', 5, 12.54864, -0.10637 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '735b2376-b3ce-2f7d-b0b0-66038cab6ec3', 5, '195903a4-f2e9-85f9-dc7d-8d7bd80c3b57', 1, 27.09018, 114.26246 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( 'aa1dac90-8173-b086-9876-eb759daf61a2', 5, '87c9f4c1-5bb6-7c71-3e7b-e463b7317ad1', 5, 88.86812, -156.95844 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( 'bb72da5a-7e53-5e41-ed8a-bfd4a305b92f', 2, '657844b7-971b-c710-533b-d9e7a06c50dd', 13, -23.34321, -135.89964 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '853c51e9-d3a9-8d11-cc2a-5bc0492c5ee3', 11, 'ea419d03-1dca-6a46-6782-35665ba1d6d2', 14, 89.77226, -179.32414 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( 'eaf5847f-f66a-1e9e-90d4-06f696465b8e', 13, 'ac6b051a-518e-134b-c601-cbbe771336ef', 7, -51.10404, -19.42546 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '396a07f1-c9c1-50d7-d14f-e422c57dae97', 12, '8fbb64d6-9e27-658a-e474-f3d33d524df5', 10, -65.79941, -101.74943 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '55e1bc8a-fc1e-e818-e564-a14beb455144', 13, '3af9fd21-2f09-7668-dd70-5e978e5e0cf3', 11, 14.62161, 109.03186 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '6517deaa-31af-30c9-3abb-4a5118eac873', 15, '6057ac4e-1620-6d37-84fb-51849cce2780', 11, -38.10655, -63.57138 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( 'ccbc1e50-d5d4-dd24-6c0b-f0e91d2ea2de', 13, 'c5fa4356-b536-12cb-adeb-60737c1b0751', 6, 65.52775, 39.63395 ); 
INSERT INTO "CarSharingComp".charging_station( uid, available_sockets, vehicle_id, capacity, latitude, longitude ) VALUES ( '1348e83a-0012-e23b-e635-03d8632361c9', 5, 'd71f0519-e9f2-fb61-c832-032cd41837af', 13, 31.39462, -105.96257 ); 

INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '972822cb-cd44-f6f3-7932-9f8d620dee68', 'free', 92480, 'Ethan', 'Lee' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'b6ba55bc-1158-6038-5c71-42d49412390d', 'works', 93666, 'Nichole', 'Griffith' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'bf442b3c-8ccd-98f3-4b18-b1a74dbce679', 'works', 36749, 'Gary', 'Stephenson' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'e86f53dc-25d3-5c17-0011-922166e96c19', 'not present', 84338, 'Christine', 'Meadows' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'c2904682-b809-26dc-1c5b-1f0255e76b38', 'not present', 23580, 'Garrison', 'Dean' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'b3dba864-ec61-d71b-1084-97f755808db3', 'free', 90817, 'Gay', 'Nelson' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'f3998d41-5b45-747d-582a-2601a992a6e5', 'works', 59919, 'Buffy', 'Ramos' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '077c26a0-a8fd-e663-766a-2926a3228a2e', 'free', 34092, 'Brittany', 'Hawkins' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '5823402b-9478-1d04-d04f-d0940d3b0cbd', 'free', 82059, 'Claudia', 'Potter' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '146dc504-b637-f64f-a89c-116a85d6a205', 'works', 42384, 'Cassidy', 'Hurley' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '8b0389bc-efbe-8007-b848-d6f6bb0c7c9b', 'free', 96632, 'Ramona', 'Acevedo' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '46d28ce0-e5be-5cc5-f30b-b59a54ee8a3a', 'free', 21783, 'Wyoming', 'Wood' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'a6dfae02-7dcb-9cbc-9152-6979517e0808', 'works', 64186, 'Jameson', 'Morrison' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '16e493e7-1dde-b35d-b8c0-8afcf0526a3b', 'not present', 96611, 'Mannix', 'Washington' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '9e29fc90-1161-1ae2-9c1d-a612a3e263e9', 'free', 84808, 'Blaze', 'Luna' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '6deb8ffd-30a5-bfe6-5ac8-4f258712a9fa', 'free', 21342, 'Blaze', 'Luna' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( 'df842696-ea72-fac7-2e6f-73b4fdf8df5a', 'free', 54643, 'Kirt', 'Brother' ); 
INSERT INTO "CarSharingComp".employee( uid, status, salary, firstname, last_name ) VALUES ( '15dba6fd-d682-7feb-a9d7-ec00c78e43d4', 'free', 75235, 'Rosal', 'Kolechko' ); 

INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '4e29c24b-959d-61be-1384-461f1bb7b88c', 15, 15, 28.60321, 139.73557 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '19830d17-261c-b05c-e479-4c9320aa3bbb', 15, 13, -81.05405, -32.61121 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( 'd676f52e-c6f9-a682-e91e-99cd9de812ed', 15, 11, -72.36504, 95.7572 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( 'e6ff7686-f049-16ff-612c-77a8fb9605ef', 15, 9, 44.01028, -39.23995 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '3ab48955-32fb-483d-7f52-52448ce8695c', 15, 12, -14.95162, -57.66188 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '04e5826c-a4e5-32c3-99d7-5188fa1fd28c', 15, 6, -1.53981, -11.43417 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( 'd860c4d7-3913-581d-0594-414d74ecd3c3', 15, 13, -13.49701, -101.40816 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '93cae2d0-1013-ef9d-192f-820081da9c3e', 15, 14, -6.55271, -94.59417 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '4c9b2744-7195-deee-8b49-4cee1d2b012d', 15, 3, 82.08745, 66.55889 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '18522927-354d-834d-5433-d3ecd577b51a', 15, 15, 36.53713, -157.99303 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( 'a0765339-c297-4558-d571-0a093c77f4e9', 15, 15, 70.61816, 37.51384 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( '9ccdf5fe-4611-a094-42f5-78e6cf281d0f', 15, 14, -38.7399, -23.38393 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( 'bc116ba8-321c-cb9c-66ea-3bcea454a743', 15, 7, 63.60654, 176.3296 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( 'ecbab451-d14c-e147-737d-9cd3cebd42ad', 15, 12, 2.40906, -170.23537 ); 
INSERT INTO "CarSharingComp".garage( uid, capacity, available_places, latitude, longitude ) VALUES ( 'fcd68d0a-74e3-c719-5c3f-6b646fca9923', 15, 15, 31.82502, 54.31957 ); 

INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M1','Volkswagen',3,'5','false','A4DAA234-0E27-E823-5955-784D1D3A05B8');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M3','Hyundai Motors',3,'2','true','18EA4D7B-7E73-D664-2504-4CF62C862C42');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M1','Citro?n',8,'3','true','E2F28F14-FC72-F862-5523-CF2CF8627FE7');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M1','Buick',3,'3','false','88F4FB19-9795-19B9-D836-2916597C845E');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M4','Porsche',6,'3','true','F7445158-3B64-7857-956B-23ADFDA62CED');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M1','Renault',8,'5','true','160F361F-5A41-DECF-F8F9-1BCC185CFE62');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M3','General Motors',7,'5','true','A368ABD7-8D50-F2EA-51F7-12C8481E5093');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M3','Audi',5,'3','false','407D8296-CDB2-4627-E146-3C7BB6B61149');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M3','Nissan',6,'2','true','52A2E3CB-EE82-0D8B-0951-60CC3FA266B5');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M2','Subaru',5,'0','true','639FAD6D-E5EC-84F1-8894-77978662D0BE');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M4','Lexus',1,'2','true','EF93CA3D-6489-1120-3F49-97C578B0545B');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M1','Isuzu',5,'0','false','6A055E5A-E092-0A72-3611-11BA06CE1719');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M3','JLR',1,'4','true','CAFB5B2F-4272-11F4-73A1-C7723D7D2A15');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M3','Lincoln',3,'2','true','62E715EF-79D9-BE11-5D55-FD491FC3067F');
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('M1','Chrysler',6,'5','true','FF28AF45-14C2-B74A-8021-CA7E44648110'); 
INSERT INTO "CarSharingComp".model (model,company,seats_number,comfort_level,is_smoking_allowed,id) VALUES ('X6','BMW',4,'5','false','D71F0519-E9F2-FB61-C832-032CD41837AF'); 

INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '49b4426f-bd04-9590-40ad-0acf36a87a1d', 'Amery', 'Kelley', 'ZZF98HUA6RT', 'risus.Donec.nibh@tortorNunccommodo.edu', 0, '347300872091869', 'NAME SURNAME', 298, '04/18' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '490d74c6-bf5f-85b6-6b49-2442e4be95c3', 'Gretchen', 'Shaffer', 'KLD78XUG1ZB', 'Cum.sociis@dictumProineget.co.uk', 0, '343269107482447', 'NAME SURNAME', 139, '27/17' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( 'e01e9827-ede9-6772-7ae4-11c459557844', 'Tanek', 'Francis', 'DUL61VOP2PN', 'metus@anteMaecenasmi.co.uk', 5, '379083715653191', 'NAME SURNAME', 637, '16/16' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '9d1eb03e-55d3-3b0b-e870-11cfd81f98d3', 'Hanna', 'Ware', 'MZF74VPL5YH', 'Donec.est.mauris@acmi.com', 2, '375894028681875', 'NAME SURNAME', 461, '09/17' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '84f29258-9e4c-14e5-5eaf-2ca5be297b79', 'Jared', 'Collins', 'RBF78VCI9ES', 'vitae@a.edu', 2, '345938072735470', 'NAME SURNAME', 842, '02/17' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( 'ac2d3220-b76a-66b3-74be-dec8f9738f06', 'Carolyn', 'King', 'IKN20TFT1ZS', 'Aliquam.auctor.velit@egetmagna.com', 7, '347317325633147', 'NAME SURNAME', 693, '29/18' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '43addf8e-896a-ff6d-8f9d-00b539888a56', 'Quin', 'Bond', 'BWK61ASX5ZQ', 'non.cursus@fringillacursuspurus.net', 0, '371778498556234', 'NAME SURNAME', 716, '17/18' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '189c624c-7a75-713f-2300-d77924dcf322', 'Len', 'Ballard', 'XVD99IRJ3YT', 'libero.est.congue@ac.com', 4, '342417645139265', 'NAME SURNAME', 921, '01/18' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '4e9061f6-9bf7-a337-70d5-9a61c9324ff3', 'Christine', 'Bishop', 'NFL06NOY4FN', 'In@arcu.ca', 2, '374906441863897', 'NAME SURNAME', 882, '04/17' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( 'b4ebe4da-fa35-eab4-9e9a-3d4fd9ae4c29', 'Ori', 'Merritt', 'BYE09YQH6LJ', 'lorem@ipsumprimis.net', 5, '375473912713431', 'NAME SURNAME', 522, '03/18' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( 'b5fd399c-6545-624b-e543-b1c3cd890db4', 'Kelsey', 'Carney', 'LAI87ZHN6ZG', 'gravida@fringillaest.net', 5, '372073224131554', 'NAME SURNAME', 589, '22/18' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( 'fb6aea69-805d-780a-02c3-b6a21579c231', 'Tatyana', 'Murray', 'YNM54WGP7DO', 'tincidunt.aliquam@scelerisque.edu', 0, '347105853513157', 'NAME SURNAME', 955, '03/17' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( 'f2f49676-93a0-0185-b916-4a4125b30a9a', 'Farrah', 'White', 'LND20ATP3EG', 'fermentum.arcu.Vestibulum@mus.org', 7, '377375236124005', 'NAME SURNAME', 569, '15/17' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '60f147eb-6b8c-945c-f3cd-54fe9569cb41', 'Aaron', 'Wallace', 'OWZ16VLX5TO', 'vel.convallis@urnanecluctus.net', 4, '347457391124751', 'NAME SURNAME', 186, '27/17' ); 
INSERT INTO "CarSharingComp"."user"( uid, first_name, last_name, user_password, email, rating, card_number, name_of_owner, cvv, date_of_out ) VALUES ( '0c8e425d-024b-210e-d708-8f66961d79a2', 'Baxter', 'Frost', 'SIV26MYU6SD', 'nibh.sit.amet@Donectempus.com', 9, '379868055274503', 'NAME SURNAME', 627, '02/17' ); 

INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '49b4426f-bd04-9590-40ad-0acf36a87a1d', 'pets' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '490d74c6-bf5f-85b6-6b49-2442e4be95c3', 'smokes' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( 'e01e9827-ede9-6772-7ae4-11c459557844', 'pets' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '9d1eb03e-55d3-3b0b-e870-11cfd81f98d3', 'smokes' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '84f29258-9e4c-14e5-5eaf-2ca5be297b79', 'children' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( 'ac2d3220-b76a-66b3-74be-dec8f9738f06', 'smokes' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '43addf8e-896a-ff6d-8f9d-00b539888a56', 'pets' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '189c624c-7a75-713f-2300-d77924dcf322', 'pets' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '4e9061f6-9bf7-a337-70d5-9a61c9324ff3', 'smokes' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( 'b4ebe4da-fa35-eab4-9e9a-3d4fd9ae4c29', 'smokes' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( 'b5fd399c-6545-624b-e543-b1c3cd890db4', 'pets' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( 'fb6aea69-805d-780a-02c3-b6a21579c231', 'children' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( 'f2f49676-93a0-0185-b916-4a4125b30a9a', 'children' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '60f147eb-6b8c-945c-f3cd-54fe9569cb41', 'children' ); 
INSERT INTO "CarSharingComp".user_preferences( uid, preference ) VALUES ( '0c8e425d-024b-210e-d708-8f66961d79a2', 'smokes' ); 

INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('red', 'AN46 LUK', 'true', 735221707, 'c0a94378-d53d-669b-fe08-dd8b5e07a67d', 'cf07940b-5fbc-c6d4-4ee7-0a6725b37d1e', '4e29c24b-959d-61be-1384-461f1bb7b88c', 'a4daa234-0e27-e823-5955-784d1d3a05b8', 2010);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('yellow', 'FB35 RZP', 'false', 652336637, '7d3440ec-69fa-330e-fc12-29723137a991', 'bfd8ccf3-3a57-a5d4-867f-5abba90d778a', '19830d17-261c-b05c-e479-4c9320aa3bbb', '18ea4d7b-7e73-d664-2504-4cf62c862c42', 2016);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('indigo', 'FV27 XZE', 'true', 379187743, 'aa30ee09-005d-3e46-c257-2ec13e94923d', '14f4433b-6eae-2e77-484f-a193d3db535b', 'd676f52e-c6f9-a682-e91e-99cd9de812ed', 'e2f28f14-fc72-f862-5523-cf2cf8627fe7', 2016);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('yellow', 'WO78 RAR', 'false', 449579473, '1e985aef-8aac-a398-1657-96d1c5eeb962', 'c3dcda66-85d8-1565-2b4a-aa27433d9cba', 'e6ff7686-f049-16ff-612c-77a8fb9605ef', '88f4fb19-9795-19b9-d836-2916597c845e', 2014);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('indigo', 'TD68 YVD', 'true', 179989025, 'e1138034-04fd-11f8-b3ac-c02180ab0cf6', '7b688d9c-d69f-1aff-ed5a-e315f06c8c20', '3ab48955-32fb-483d-7f52-52448ce8695c', 'f7445158-3b64-7857-956b-23adfda62ced', 2011);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('green', 'SV98 TZP', 'true', 738267368, '195903a4-f2e9-85f9-dc7d-8d7bd80c3b57', '735b2376-b3ce-2f7d-b0b0-66038cab6ec3', '04e5826c-a4e5-32c3-99d7-5188fa1fd28c', '160f361f-5a41-decf-f8f9-1bcc185cfe62', 2014);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('red', 'AN09 XMF', 'false', 616139259, '87c9f4c1-5bb6-7c71-3e7b-e463b7317ad1', 'aa1dac90-8173-b086-9876-eb759daf61a2', 'd860c4d7-3913-581d-0594-414d74ecd3c3', 'a368abd7-8d50-f2ea-51f7-12c8481e5093', 2013);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('blue', 'IW08 SPE', 'true', 714276920, '657844b7-971b-c710-533b-d9e7a06c50dd', 'bb72da5a-7e53-5e41-ed8a-bfd4a305b92f', '93cae2d0-1013-ef9d-192f-820081da9c3e', '407d8296-cdb2-4627-e146-3c7bb6b61149', 2012);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('blue', 'EN44 JFJ', 'false', 116581489, 'ea419d03-1dca-6a46-6782-35665ba1d6d2', '853c51e9-d3a9-8d11-cc2a-5bc0492c5ee3', '4c9b2744-7195-deee-8b49-4cee1d2b012d', '52a2e3cb-ee82-0d8b-0951-60cc3fa266b5', 2017);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('violet', 'ST51 GSJ', 'false', 26274423, 'ac6b051a-518e-134b-c601-cbbe771336ef', 'eaf5847f-f66a-1e9e-90d4-06f696465b8e', '18522927-354d-834d-5433-d3ecd577b51a', '639fad6d-e5ec-84f1-8894-77978662d0be', 2010);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('red', 'AN38 KIU', 'false', 636822058, '8fbb64d6-9e27-658a-e474-f3d33d524df5', '396a07f1-c9c1-50d7-d14f-e422c57dae97', 'a0765339-c297-4558-d571-0a093c77f4e9', 'ef93ca3d-6489-1120-3f49-97c578b0545b', 2012);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('yellow', 'WW93 WCQ', 'true', 950542993, '3af9fd21-2f09-7668-dd70-5e978e5e0cf3', '55e1bc8a-fc1e-e818-e564-a14beb455144', '9ccdf5fe-4611-a094-42f5-78e6cf281d0f', '6a055e5a-e092-0a72-3611-11ba06ce1719', 2014);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('blue', 'CD53 ORW', 'true', 643698517, '6057ac4e-1620-6d37-84fb-51849cce2780', '6517deaa-31af-30c9-3abb-4a5118eac873', 'bc116ba8-321c-cb9c-66ea-3bcea454a743', 'cafb5b2f-4272-11f4-73a1-c7723d7d2a15', 2017);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('orange', 'JS84 EPR', 'false', 545051419, 'c5fa4356-b536-12cb-adeb-60737c1b0751', 'ccbc1e50-d5d4-dd24-6c0b-f0e91d2ea2de', 'ecbab451-d14c-e147-737d-9cd3cebd42ad', '62e715ef-79d9-be11-5d55-fd491fc3067f', 2015);
INSERT INTO "CarSharingComp".vehicle (color, car_number, pets_allowing, ensurance_id, uid, charging_id, garage_id, model_id, vehicle_year) VALUES ('blue', 'TO56 GAD', 'false', 571954544, 'd71f0519-e9f2-fb61-c832-032cd41837af', '1348e83a-0012-e23b-e635-03d8632361c9', 'fcd68d0a-74e3-c719-5c3f-6b646fca9923', 'ff28af45-14c2-b74a-8021-ca7e44648110', 2017);

INSERT INTO "CarSharingComp".administrator (username,password,is_a_head_administrator,employee_id) VALUES ('KIQ82QVU0BE','TSB68EKV5UV','true','6DEB8FFD-30A5-BFE6-5AC8-4F258712A9FA');
INSERT INTO "CarSharingComp".administrator (username,password,is_a_head_administrator,employee_id) VALUES ('NJR96DZG4YC','OZY92ENZ3FI','false','DF842696-EA72-FAC7-2E6F-73B4FDF8DF5A');
INSERT INTO "CarSharingComp".administrator (username,password,is_a_head_administrator,employee_id) VALUES ('WWA57BMZ2LT','BJT49UQO2ZL','false','15DBA6FD-D682-7FEB-A9D7-EC00C78E43D4');

INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( 'c0a94378-d53d-669b-fe08-dd8b5e07a67d', 17002, 'busy', 84, '2017-12-28 09:16:01+03', 64.79648, -70.21674 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '7d3440ec-69fa-330e-fc12-29723137a991', 19859, 'free', 38, '2017-11-08 19:03:17+03', 21.86822, 34.53704 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( 'aa30ee09-005d-3e46-c257-2ec13e94923d', 19968, 'busy', 62, '2017-11-21 03:43:23+03', 41.29033, 33.04844 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '1e985aef-8aac-a398-1657-96d1c5eeb962', 10731, 'repairing', 24, '2016-12-11 14:59:49+03', 57.37923, -83.09628 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( 'e1138034-04fd-11f8-b3ac-c02180ab0cf6', 22759, 'repairing', 70, '2017-07-07 04:56:17+03', 10.24373, -73.63035 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '195903a4-f2e9-85f9-dc7d-8d7bd80c3b57', 28867, 'free', 4, '2017-01-24 02:38:24+03', -41.49041, -14.63392 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '87c9f4c1-5bb6-7c71-3e7b-e463b7317ad1', 22080, 'in garage', 16, '2018-08-21 12:17:58+03', 11.74207, 77.13561 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '657844b7-971b-c710-533b-d9e7a06c50dd', 1132, 'busy', 30, '2016-11-23 11:30:45+03', -10.2896, 38.59247 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( 'ea419d03-1dca-6a46-6782-35665ba1d6d2', 16027, 'in garage', 27, '2017-05-17 03:11:24+03', 20.6391, 130.81429 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( 'ac6b051a-518e-134b-c601-cbbe771336ef', 9412, 'in garage', 40, '2017-09-25 14:06:00+03', -76.07069, 140.06879 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '8fbb64d6-9e27-658a-e474-f3d33d524df5', 18459, 'in garage', 71, '2018-11-15 06:33:23+03', -82.94501, 175.79695 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '3af9fd21-2f09-7668-dd70-5e978e5e0cf3', 26844, 'in garage', 76, '2018-04-22 10:24:03+03', 77.71317, 40.36807 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( '6057ac4e-1620-6d37-84fb-51849cce2780', 18872, 'busy', 64, '2018-02-19 13:32:34+03', 32.45438, -41.41957 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( 'c5fa4356-b536-12cb-adeb-60737c1b0751', 25293, 'in garage', 49, '2018-11-08 03:43:45+03', 53.85835, -74.56396 ); 
INSERT INTO "CarSharingComp".dinamic_data_vehicle( vehicle_id, mileage, vehicle_state, charge_level, next_diagnoses_date, latitude, longitude ) VALUES ( 'd71f0519-e9f2-fb61-c832-032cd41837af', 9400, 'free', 37, '2017-12-10 10:10:56+03', -21.08447, 53.16273 ); 

INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('C0A94378-D53D-669B-FE08-DD8B5E07A67D','false');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('7D3440EC-69FA-330E-FC12-29723137A991','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('AA30EE09-005D-3E46-C257-2EC13E94923D','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('1E985AEF-8AAC-A398-1657-96D1C5EEB962','false');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('E1138034-04FD-11F8-B3AC-C02180AB0CF6','false');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('195903A4-F2E9-85F9-DC7D-8D7BD80C3B57','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('87C9F4C1-5BB6-7C71-3E7B-E463B7317AD1','false');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('657844B7-971B-C710-533B-D9E7A06C50DD','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('EA419D03-1DCA-6A46-6782-35665BA1D6D2','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('AC6B051A-518E-134B-C601-CBBE771336EF','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('8FBB64D6-9E27-658A-E474-F3D33D524DF5','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('3AF9FD21-2F09-7668-DD70-5E978E5E0CF3','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('6057AC4E-1620-6D37-84FB-51849CCE2780','false');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('C5FA4356-B536-12CB-ADEB-60737C1B0751','true');
INSERT INTO "CarSharingComp".emergency_service_team (id,available) VALUES ('D71F0519-E9F2-FB61-C832-032CD41837AF','false');

INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '49b4426f-bd04-9590-40ad-0acf36a87a1d', 66.04892, -163.6459 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '490d74c6-bf5f-85b6-6b49-2442e4be95c3', 57.67263, 58.91186 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( 'e01e9827-ede9-6772-7ae4-11c459557844', -72.89974, 172.30756 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '9d1eb03e-55d3-3b0b-e870-11cfd81f98d3', 41.54284, 41.30222 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '84f29258-9e4c-14e5-5eaf-2ca5be297b79', 27.25957, -23.54701 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( 'ac2d3220-b76a-66b3-74be-dec8f9738f06', -16.9141, 51.01223 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '43addf8e-896a-ff6d-8f9d-00b539888a56', 48.41774, -115.06811 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '189c624c-7a75-713f-2300-d77924dcf322', -44.59456, 121.63427 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '4e9061f6-9bf7-a337-70d5-9a61c9324ff3', -45.99126, -44.52014 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( 'b4ebe4da-fa35-eab4-9e9a-3d4fd9ae4c29', -81.12329, -166.12344 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( 'b5fd399c-6545-624b-e543-b1c3cd890db4', -53.12443, -124.77202 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( 'fb6aea69-805d-780a-02c3-b6a21579c231', -64.99457, -76.22412 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( 'f2f49676-93a0-0185-b916-4a4125b30a9a', -5.3964, 25.23198 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '60f147eb-6b8c-945c-f3cd-54fe9569cb41', 83.34159, -179.15662 ); 
INSERT INTO "CarSharingComp".location_of_residence( uid, latitude, longitude ) VALUES ( '0c8e425d-024b-210e-d708-8f66961d79a2', -88.80525, 120.54191 ); 

INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'electric', '972822cb-cd44-f6f3-7932-9f8d620dee68', '4e29c24b-959d-61be-1384-461f1bb7b88c', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'wheels', 'b6ba55bc-1158-6038-5c71-42d49412390d', '19830d17-261c-b05c-e479-4c9320aa3bbb', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'carcase', 'bf442b3c-8ccd-98f3-4b18-b1a74dbce679', 'd676f52e-c6f9-a682-e91e-99cd9de812ed', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'electric', 'e86f53dc-25d3-5c17-0011-922166e96c19', 'e6ff7686-f049-16ff-612c-77a8fb9605ef', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'engine', 'c2904682-b809-26dc-1c5b-1f0255e76b38', '3ab48955-32fb-483d-7f52-52448ce8695c', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'carcase', 'b3dba864-ec61-d71b-1084-97f755808db3', '04e5826c-a4e5-32c3-99d7-5188fa1fd28c', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'engine', 'f3998d41-5b45-747d-582a-2601a992a6e5', 'd860c4d7-3913-581d-0594-414d74ecd3c3', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'engine', '077c26a0-a8fd-e663-766a-2926a3228a2e', '93cae2d0-1013-ef9d-192f-820081da9c3e', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'electric', '5823402b-9478-1d04-d04f-d0940d3b0cbd', '4c9b2744-7195-deee-8b49-4cee1d2b012d', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'carcase', '146dc504-b637-f64f-a89c-116a85d6a205', '18522927-354d-834d-5433-d3ecd577b51a', null ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'carcase', '8b0389bc-efbe-8007-b848-d6f6bb0c7c9b', null, '8fbb64d6-9e27-658a-e474-f3d33d524df5' ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'wheels', '46d28ce0-e5be-5cc5-f30b-b59a54ee8a3a', null, '3af9fd21-2f09-7668-dd70-5e978e5e0cf3' ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'electric', 'a6dfae02-7dcb-9cbc-9152-6979517e0808', null, '6057ac4e-1620-6d37-84fb-51849cce2780' ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'engine', '16e493e7-1dde-b35d-b8c0-8afcf0526a3b', null, 'c5fa4356-b536-12cb-adeb-60737c1b0751' ); 
INSERT INTO "CarSharingComp".mechanics( speciality, employee_id, works_in, in_team ) VALUES ( 'engine', '9e29fc90-1161-1ae2-9c1d-a612a3e263e9', null, 'd71f0519-e9f2-fb61-c832-032cd41837af' ); 

INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('88b8c646-8d1f-fa4a-8892-9a7d29fccd07', 4, 'true', 'false', 'false', '2017-11-19 13:34:18+03', 3, 'mauris eu elit.', 'done', '84f29258-9e4c-14e5-5eaf-2ca5be297b79', 'e1138034-04fd-11f8-b3ac-c02180ab0cf6', 9, '2017-11-19 13:57:47+03', 58.688591, 71.8206024, 60.263649, -126.611328);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('5770ddfa-3792-4262-96d3-be2e5611095f', 4, 'true', 'true', 'false', '2017-11-23 02:10:34+03', 1, 'nisl. Maecenas malesuada fringilla est. Mauris', 'new', 'b4ebe4da-fa35-eab4-9e9a-3d4fd9ae4c29', '8fbb64d6-9e27-658a-e474-f3d33d524df5', 8, '2017-11-23 03:18:20+03', 49.8276901, -58.0419197, -58.1460609, -178.370743);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('a4b4c4e1-12cf-4a7b-c6bd-aff7fdd65af6', 8, 'true', 'false', 'false', '2017-11-23 18:04:18+03', 0, 'volutpat ornare, facilisis eget, ipsum. Donec sollicitudin adipiscing', 'new', '0c8e425d-024b-210e-d708-8f66961d79a2', 'd71f0519-e9f2-fb61-c832-032cd41837af', 14, '2017-11-23 18:32:53+03', 13.5687504, -137.009109, 77.9720993, 116.536171);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('9fd6178e-4b49-25a9-d322-cfe27bd90183', 7, 'false', 'true', 'false', '2017-11-16 11:56:55+03', 1, 'neque. In ornare sagittis felis.', 'in process', '189c624c-7a75-713f-2300-d77924dcf322', 'ea419d03-1dca-6a46-6782-35665ba1d6d2', 20, '2017-11-16 12:11:03+03', 5.99770021, 24.2175503, 58.1345482, 81.6825638);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('af1725f8-82a0-c20f-4f87-406433bb4932', 6, 'true', 'false', 'false', '2017-11-23 12:42:19+03', 3, 'tempor augue ac ipsum. Phasellus vitae', 'in process', '43addf8e-896a-ff6d-8f9d-00b539888a56', '1e985aef-8aac-a398-1657-96d1c5eeb962', 18, '2017-11-23 13:40:22+03', 50.7630997, -83.7352829, 19.1912308, 144.547073);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('a57449f9-5da4-69c3-048a-74d9d4759e67', 7, 'false', 'true', 'false', '2017-11-24 07:19:27+03', 0, 'metus. In lorem.', 'done', '9d1eb03e-55d3-3b0b-e870-11cfd81f98d3', '1e985aef-8aac-a398-1657-96d1c5eeb962', 23, '2017-11-24 07:26:35+03', 40.5353394, 68.6443405, 19.1912308, 144.547073);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('d8628d10-ee43-81da-8b70-95615174ecc5', 7, 'false', 'true', 'true', '2017-11-23 17:34:46+03', 3, 'vehicula aliquet libero. Integer in magna. Phasellus dolor elit,', 'new', 'ac2d3220-b76a-66b3-74be-dec8f9738f06', '1e985aef-8aac-a398-1657-96d1c5eeb962', 5, '2017-11-23 17:57:12+03', -62.0894699, -5.11197996, 86.6247177, -21.1198101);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('14d3a2aa-f984-17b3-41a3-df9d2f835334', 3, 'false', 'false', 'true', '2017-11-22 13:48:19+03', 2, 'at, egestas a, scelerisque', 'in process', 'f2f49676-93a0-0185-b916-4a4125b30a9a', '6057ac4e-1620-6d37-84fb-51849cce2780', 5, '2017-11-22 15:39:31+03', 69.2385864, 103.334923, 45.0736198, -111.868332);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('00ff9d2c-6dc5-9a26-041f-545db25b4862', 3, 'true', 'true', 'true', '2017-11-19 09:22:18+03', 3, 'tempor lorem, eget mollis', 'done', '4e9061f6-9bf7-a337-70d5-9a61c9324ff3', 'ea419d03-1dca-6a46-6782-35665ba1d6d2', 10, '2017-11-19 09:48:33+03', 5.99770021, 24.2175503, 45.0736198, -111.868332);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('43847033-b476-25d5-4c8f-4c7e8e1012c7', 1, 'true', 'true', 'true', '2017-11-22 17:10:39+03', 1, 'id enim. Curabitur massa. Vestibulum accumsan', 'new', '60f147eb-6b8c-945c-f3cd-54fe9569cb41', '6057ac4e-1620-6d37-84fb-51849cce2780', 15, '2017-11-22 17:47:45+03', 15.7297497, -81.154808, 82.6940384, 167.698456);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('33ecd57f-6fe8-8730-b92c-61e14add65cb', 1, 'false', 'false', 'false', '2017-11-21 09:21:34+03', 1, 'placerat velit. Quisque varius. Nam porttitor scelerisque', 'done', '490d74c6-bf5f-85b6-6b49-2442e4be95c3', 'c0a94378-d53d-669b-fe08-dd8b5e07a67d', 3, '2017-11-21 10:18:29+03', 58.688591, 71.8206024, -52.0140991, -42.1385307);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('4e4d96b3-fd99-0efe-2b63-97d3b2085fd1', 8, 'true', 'true', 'false', '2017-11-22 18:58:57+03', 2, 'at, velit.', 'new', 'b5fd399c-6545-624b-e543-b1c3cd890db4', '195903a4-f2e9-85f9-dc7d-8d7bd80c3b57', 13, '2017-11-22 19:24:51+03', 5.99770021, 24.2175503, 52.9260902, 72.2860794);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('4930fad5-d429-8e20-1f82-fb85c6c03be9', 4, 'true', 'true', 'true', '2017-11-23 12:48:35+03', 1, 'ridiculus mus. Donec', 'in process', '49b4426f-bd04-9590-40ad-0acf36a87a1d', 'c0a94378-d53d-669b-fe08-dd8b5e07a67d', 18, '2017-11-23 12:59:21+03', 40.5353394, 68.6443405, 60.263649, -126.611328);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('9ab68f4c-27b7-1477-efa6-01e82e19ca60', 7, 'false', 'true', 'false', '2017-11-23 15:07:08+03', 1, 'eget varius ultrices, mauris ipsum porta elit, a feugiat tellus', 'in process', 'fb6aea69-805d-780a-02c3-b6a21579c231', 'ea419d03-1dca-6a46-6782-35665ba1d6d2', 17, '2017-12-23 15:55:18+03', 15.7297497, -81.154808, 82.6115875, 13.6890097);
INSERT INTO "CarSharingComp"."order" (id, number_of_passengers, luggage, is_smoking_allowed, are_pets_allowed, created_on, number_of_children_under_12, feedback_of_ride, order_state, user_id, vehicle_id, distance, departure_time, source_latitude, source_longitude, dest_latitude, dest_longitude) VALUES ('9277d734-d43b-84f9-d47b-be99958a2f32', 4, 'true', 'true', 'false', '2017-11-20 07:52:37+03', 1, 'consequat enim diam vel arcu. Curabitur ut odio vel est', 'in process', 'e01e9827-ede9-6772-7ae4-11c459557844', 'c0a94378-d53d-669b-fe08-dd8b5e07a67d', 6, '2017-11-20 08:38:14+03', 58.688591, 71.8206024, -52.0140991, -42.1385307);

INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '78858269-5726-d75c-f29e-53e00e6aa5e5', 'augue, eu tempor erat neque non quam. Pellentesque habitant morbi', 'c0a94378-d53d-669b-fe08-dd8b5e07a67d' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( 'acbdf3e6-a116-c835-9bfc-4c283e62eece', 'enim, condimentum', '7d3440ec-69fa-330e-fc12-29723137a991' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( 'd81d7dd3-121e-4b4b-003a-3283988827ed', 'amet', 'aa30ee09-005d-3e46-c257-2ec13e94923d' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( 'c45b5194-856e-064a-ecdd-c842b16b6202', 'a, malesuada', '1e985aef-8aac-a398-1657-96d1c5eeb962' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( 'e3daef6c-5c04-0f6e-f136-c8406d3eef6e', 'ante bibendum ullamcorper. Duis cursus, diam', 'e1138034-04fd-11f8-b3ac-c02180ab0cf6' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '1c2abd9c-7881-c27f-98cb-6453b361c990', 'lorem lorem, luctus ut, pellentesque eget, dictum placerat, augue.', '195903a4-f2e9-85f9-dc7d-8d7bd80c3b57' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '21cd4f35-61c4-3e45-1350-637779b15e93', 'magna et ipsum cursus vestibulum. Mauris magna. Duis', '87c9f4c1-5bb6-7c71-3e7b-e463b7317ad1' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( 'c93186b5-b584-b23b-10ac-56168d1b9812', 'adipiscing, enim mi tempor lorem, eget mollis lectus pede et', '657844b7-971b-c710-533b-d9e7a06c50dd' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '3e1bb366-6c5d-6fea-3828-ec06eb8910e8', 'magna. Sed eu eros. Nam consequat dolor vitae dolor.', 'ea419d03-1dca-6a46-6782-35665ba1d6d2' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( 'a6ce361d-67f2-ca25-7dc1-6517b456e550', 'nec ante. Maecenas mi felis,', 'ac6b051a-518e-134b-c601-cbbe771336ef' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '29b832fc-a33c-b858-d565-0026d72c2bb4', 'orci. Ut semper pretium neque. Morbi quis', '8fbb64d6-9e27-658a-e474-f3d33d524df5' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '80a900f6-7d69-cdeb-aa58-10d5d83693c4', 'netus', '3af9fd21-2f09-7668-dd70-5e978e5e0cf3' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '8861d67c-1cc9-beea-3c60-25de1b6515e4', 'a neque. Nullam ut nisi', '6057ac4e-1620-6d37-84fb-51849cce2780' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( 'fa272898-e236-3e44-e6f1-6e4eaafd0fe9', 'elit. Curabitur sed tortor. Integer aliquam adipiscing lacus.', 'c5fa4356-b536-12cb-adeb-60737c1b0751' ); 
INSERT INTO "CarSharingComp".reports( uid, text, team_id ) VALUES ( '9a96e514-cc55-ab5b-080d-2d87e8702080', 'libero', 'd71f0519-e9f2-fb61-c832-032cd41837af' ); 

INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '4a249361-733e-2d71-08f4-919c30d52422', 'Suspendisse sed', '49b4426f-bd04-9590-40ad-0acf36a87a1d', '2017-04-12', '6deb8ffd-30a5-bfe6-5ac8-4f258712a9fa' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( 'c16ef3ce-95d3-a996-baa1-881dcef4b239', 'semper cursus. Integer mollis. Integer tincidunt aliquam arcu. Aliquam', '490d74c6-bf5f-85b6-6b49-2442e4be95c3', '2017-04-18', '6deb8ffd-30a5-bfe6-5ac8-4f258712a9fa' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '2cf70dd5-9934-9ab0-debf-fe886098a16d', 'risus. Morbi metus. Vivamus euismod', 'e01e9827-ede9-6772-7ae4-11c459557844', '2018-09-28', '6deb8ffd-30a5-bfe6-5ac8-4f258712a9fa' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( 'c800452d-413f-6be5-7667-212547f5ff94', 'congue, elit sed consequat auctor, nunc nulla vulputate dui,', '9d1eb03e-55d3-3b0b-e870-11cfd81f98d3', '2017-11-30', '6deb8ffd-30a5-bfe6-5ac8-4f258712a9fa' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '15ccce0c-d745-1500-ab32-74cf62309f5f', 'Integer urna. Vivamus molestie dapibus ligula. Aliquam erat volutpat. Nulla', '84f29258-9e4c-14e5-5eaf-2ca5be297b79', '2016-12-27', '6deb8ffd-30a5-bfe6-5ac8-4f258712a9fa' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '8f9cfccb-e25b-e856-bf69-587253d78b79', 'Phasellus vitae mauris sit amet', 'ac2d3220-b76a-66b3-74be-dec8f9738f06', '2017-03-02', 'df842696-ea72-fac7-2e6f-73b4fdf8df5a' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '8ce24c89-4224-bace-4504-c0a6a561f2d2', 'egestas hendrerit neque. In', '43addf8e-896a-ff6d-8f9d-00b539888a56', '2017-02-07', 'df842696-ea72-fac7-2e6f-73b4fdf8df5a' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '5b1ab1d5-7f4a-b9e5-9dde-ccee5f292aae', 'nec, diam. Duis mi enim, condimentum eget, volutpat ornare, facilisis', '189c624c-7a75-713f-2300-d77924dcf322', '2017-09-23', 'df842696-ea72-fac7-2e6f-73b4fdf8df5a' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '84c80fd6-df65-922d-4bad-2b018445fef8', 'Maecenas iaculis aliquet diam. Sed diam', '4e9061f6-9bf7-a337-70d5-9a61c9324ff3', '2018-03-07', 'df842696-ea72-fac7-2e6f-73b4fdf8df5a' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( 'c6874671-39b0-1c76-6e5c-0e9d2b015b4d', 'dictum augue malesuada malesuada. Integer id magna', 'b4ebe4da-fa35-eab4-9e9a-3d4fd9ae4c29', '2017-11-22', 'df842696-ea72-fac7-2e6f-73b4fdf8df5a' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( 'e3b5b626-7238-f7eb-6477-acfe7ba503a0', 'turpis. In condimentum. Donec at arcu. Vestibulum', 'b5fd399c-6545-624b-e543-b1c3cd890db4', '2017-03-05', '15dba6fd-d682-7feb-a9d7-ec00c78e43d4' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '71bcaaf9-c968-5618-51d6-86517cf9fa58', 'adipiscing non, luctus sit amet,', 'fb6aea69-805d-780a-02c3-b6a21579c231', '2018-06-01', '15dba6fd-d682-7feb-a9d7-ec00c78e43d4' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( '15225b6a-25d5-0c63-569f-752240e3422d', 'libero nec ligula', 'f2f49676-93a0-0185-b916-4a4125b30a9a', '2017-01-24', '15dba6fd-d682-7feb-a9d7-ec00c78e43d4' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( 'd0eec4e8-8b86-5c73-6c41-0428c1625ce6', 'non magna. Nam ligula elit, pretium et, rutrum non, hendrerit', '60f147eb-6b8c-945c-f3cd-54fe9569cb41', '2018-09-12', '15dba6fd-d682-7feb-a9d7-ec00c78e43d4' ); 
INSERT INTO "CarSharingComp".request( uid, text, user_id, created_on, admin_id ) VALUES ( 'd5d5426d-41bb-bbf5-49dd-7e24b7588eb2', 'aliquam adipiscing lacus.', '0c8e425d-024b-210e-d708-8f66961d79a2', '2017-07-01', '15dba6fd-d682-7feb-a9d7-ec00c78e43d4' ); 

INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'fe0f131b-d92d-8976-601d-92c81d5ff966', 'in process', 'A', 'c0a94378-d53d-669b-fe08-dd8b5e07a67d', '2017-07-29 09:23:28+03', -8.34928, -72.50976 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'b11856d2-647d-2458-f0a5-da56a2841729', 'new', 'A', '7d3440ec-69fa-330e-fc12-29723137a991', '2017-07-18 13:39:40+03', -53.16913, -25.86295 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'f37f03de-8a92-ef51-f238-61687e9f4c4f', 'new', 'C', 'aa30ee09-005d-3e46-c257-2ec13e94923d', '2017-06-23 02:23:24+03', -4.49656, 52.4661 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'a0ba67a3-1c96-bb72-9276-6c25318de4a5', 'new', 'A', '1e985aef-8aac-a398-1657-96d1c5eeb962', '2018-07-07 06:53:05+03', -26.45176, -19.75994 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'dc268308-3830-6054-5284-1c9dc356aa11', 'in process', 'B', 'e1138034-04fd-11f8-b3ac-c02180ab0cf6', '2018-10-29 06:14:43+03', -26.42778, -12.99775 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( '409dc361-9fbd-d283-bb87-70d6e6e60c90', 'new', 'A', '195903a4-f2e9-85f9-dc7d-8d7bd80c3b57', '2017-04-03 16:33:51+03', 49.84227, 42.02899 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( '03096c27-f7dc-f53a-94b9-ea97d496b70f', 'in process', 'B', '87c9f4c1-5bb6-7c71-3e7b-e463b7317ad1', '2017-03-09 04:15:00+03', 4.74661, -66.06344 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( '3955951a-0982-e019-0566-debe03da1fe5', 'new', 'A', '657844b7-971b-c710-533b-d9e7a06c50dd', '2018-10-17 21:31:37+03', 65.87321, 58.80372 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'e3c6431c-79e2-2979-852a-d2e96565713e', 'in process', 'A', 'ea419d03-1dca-6a46-6782-35665ba1d6d2', '2017-06-17 07:12:29+03', -25.36226, -146.65826 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( '72bf9d1d-288f-4fb0-dc94-8b14e2aba972', 'in process', 'C', 'ac6b051a-518e-134b-c601-cbbe771336ef', '2018-03-28 00:10:56+03', -24.56154, 46.31415 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( '43e3c610-238d-17b0-26dd-e748bb5bf8ec', 'new', 'B', '8fbb64d6-9e27-658a-e474-f3d33d524df5', '2018-07-11 08:51:27+03', -7.65294, 11.89278 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'f41df14b-c250-e6a0-3799-5d4b7bc91cdd', 'new', 'C', '3af9fd21-2f09-7668-dd70-5e978e5e0cf3', '2017-11-22 03:25:30+03', 37.83519, 75.63831 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( 'ed0bec5f-5b02-ffe6-4fe3-35770724a6db', 'in process', 'B', '6057ac4e-1620-6d37-84fb-51849cce2780', '2017-02-10 16:02:15+03', 21.91051, -95.51474 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( '21a87226-9614-6342-8714-77f66c73195d', 'new', 'C', 'c5fa4356-b536-12cb-adeb-60737c1b0751', '2017-02-06 15:34:08+03', -19.0764, -118.59167 ); 
INSERT INTO "CarSharingComp".request_from_car( id, status, request_type, vehicle_id, created_on, latitude, longitude ) VALUES ( '5f9af934-866e-1a61-8be0-8182c68c6a91', 'in process', 'C', 'd71f0519-e9f2-fb61-c832-032cd41837af', '2018-08-26 15:07:58+03', -5.77971, -14.18931 ); 
