package com.pichincha;

import com.intuit.karate.junit5.Karate;

class TestRunner {
    
    @Karate.Test
    Karate testMarvelCharactersApi() {
        return Karate.run("features/marvel_characters_api/gestionPersonajes.feature").relativeTo(getClass());
    }
}
