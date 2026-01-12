insert into team_routing_rules
(issue_type, default_team, default_severity, slack_channel, sla_hours)
values
('SCHEDULING', 'CARE', 'MED', '#care-ops', 24),
('MEDICATION', 'CLINICAL', 'HIGH', '#clinical-ops', 12),
('EMR/TECH', 'PRODUCT', 'MED', '#product-ops', 48),
('DATA/REPORTING', 'DATA', 'MED', '#data-ops', 72),
('OTHER', 'OPS', 'LOW', '#ops', 72);

