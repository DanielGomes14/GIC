import rollup_builds from "./includes/rollup_builds";
import pckg from '../package.json';

const dists = rollup_builds( './src/index.js', "./out", pckg );

export default [
	dists.browser("./dist/mediacms-vjs-plugin.js"),
    // dists.browser("./dist/mediacms-vjs-plugin.js", true),
    // dists.browser("./dist/mediacms-vjs-plugin.min.js", true, true),
    // dists.browser("./dist/mediacms-vjs-plugin.min.js", true, true, true)
];