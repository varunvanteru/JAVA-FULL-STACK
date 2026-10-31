package com.codequest.model;

/**
 * Plain Java class (POJO) that carries one row of the missions table
 * from a Servlet to a JSP page.
 * NOTE: correctAnswer is never filled when sending missions to students.
 */
public class Mission {

    private int id;
    private String title;
    private String description;
    private String category;
    private String difficulty;
    private String optionA;
    private String optionB;
    private String optionC;
    private String optionD;
    private String correctAnswer;
    private int xpReward;
    private boolean attempted;      // used on missions page for the logged-in student
    private boolean solvedCorrectly;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDifficulty() { return difficulty; }
    public void setDifficulty(String difficulty) { this.difficulty = difficulty; }

    public String getOptionA() { return optionA; }
    public void setOptionA(String optionA) { this.optionA = optionA; }

    public String getOptionB() { return optionB; }
    public void setOptionB(String optionB) { this.optionB = optionB; }

    public String getOptionC() { return optionC; }
    public void setOptionC(String optionC) { this.optionC = optionC; }

    public String getOptionD() { return optionD; }
    public void setOptionD(String optionD) { this.optionD = optionD; }

    public String getCorrectAnswer() { return correctAnswer; }
    public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }

    public int getXpReward() { return xpReward; }
    public void setXpReward(int xpReward) { this.xpReward = xpReward; }

    public boolean isAttempted() { return attempted; }
    public void setAttempted(boolean attempted) { this.attempted = attempted; }

    public boolean isSolvedCorrectly() { return solvedCorrectly; }
    public void setSolvedCorrectly(boolean solvedCorrectly) { this.solvedCorrectly = solvedCorrectly; }
}
